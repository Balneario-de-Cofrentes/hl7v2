defmodule HL7v2.MLLP.Connection do
  @moduledoc """
  Ranch protocol handler for MLLP connections.

  Manages the lifecycle of a single MLLP connection:

  1. Accept the TCP connection via Ranch handshake
  2. Read data, buffering until a complete MLLP frame arrives
  3. Extract the message, invoke the configured handler
  4. Frame the response and send it back
  5. Continue reading (MLLP connections are persistent)
  6. Handle timeouts and disconnects gracefully

  ## Options (passed through from `HL7v2.MLLP.Listener`)

  - `:handler` (required) — module implementing `HL7v2.MLLP.Handler`.
  - `:handler_state` — arbitrary term passed to the handler in metadata.
  - `:timeout` — idle connection timeout in milliseconds (default: `60_000`).
  - `:max_message_size` — maximum allowed buffer size in bytes before the
    connection is closed (default: `10_485_760` — 10 MB). Protects against
    memory exhaustion from misbehaving or malicious senders.
  - `:handler_timeout` — maximum time in milliseconds to wait for the handler
    to return (default: `60_000`). If the handler does not respond within this
    window, the handler process is killed and the connection continues accepting
    new messages.

  ## Telemetry events

  - `[:hl7v2, :mllp, :connection, :start]` — emitted when a connection is accepted
    - Measurements: `%{system_time: integer()}`
    - Metadata: `%{ref: term(), peer: {address, port}}`

  - `[:hl7v2, :mllp, :connection, :stop]` — emitted when a connection closes
    - Measurements: `%{duration: integer()}`
    - Metadata: `%{ref: term(), peer: {address, port}, reason: term()}`

  - `[:hl7v2, :mllp, :message, :start]` — emitted before handler invocation
    - Measurements: `%{system_time: integer()}`
    - Metadata: `%{ref: term(), peer: {address, port}, message_size: integer()}`

  - `[:hl7v2, :mllp, :message, :stop]` — emitted after handler returns
    - Measurements: `%{duration: integer()}`
    - Metadata: `%{ref: term(), peer: {address, port}, response_size: integer()}`

  - `[:hl7v2, :mllp, :message, :exception]` — emitted when handler raises, errors, or times out
    - Measurements: `%{duration: integer()}`
    - Metadata: `%{ref: term(), peer: {address, port}, kind: term(), reason: term(), stacktrace: list()}`

  """

  @behaviour :ranch_protocol

  require Logger

  @default_timeout 60_000
  @default_max_message_size 10_485_760
  @default_handler_timeout 60_000

  @impl :ranch_protocol
  @doc false
  @spec start_link(:ranch.ref(), module(), keyword()) :: {:ok, pid()}
  def start_link(ref, transport, opts) do
    pid = :proc_lib.spawn_link(__MODULE__, :init, [ref, transport, opts])
    {:ok, pid}
  end

  @doc false
  @spec init(:ranch.ref(), module(), keyword()) :: :ok
  def init(ref, transport, opts) do
    {:ok, socket} = :ranch.handshake(ref)

    handler = Keyword.fetch!(opts, :handler)
    handler_state = Keyword.get(opts, :handler_state)
    timeout = Keyword.get(opts, :timeout, @default_timeout)
    max_message_size = Keyword.get(opts, :max_message_size, @default_max_message_size)
    handler_timeout = Keyword.get(opts, :handler_timeout, @default_handler_timeout)

    peer = peer_info(transport, socket)
    conn_start = System.monotonic_time()

    :telemetry.execute(
      [:hl7v2, :mllp, :connection, :start],
      %{system_time: System.system_time()},
      %{ref: ref, peer: peer}
    )

    meta = %{peer: peer, ref: ref, handler_state: handler_state}

    config = %{
      handler: handler,
      timeout: timeout,
      max_message_size: max_message_size,
      handler_timeout: handler_timeout
    }

    try do
      loop(transport, socket, config, meta, <<>>)
    after
      duration = System.monotonic_time() - conn_start

      :telemetry.execute(
        [:hl7v2, :mllp, :connection, :stop],
        %{duration: duration},
        %{ref: ref, peer: peer, reason: :normal}
      )

      transport.close(socket)
    end
  end

  defp loop(transport, socket, config, meta, buffer) do
    transport.setopts(socket, active: :once)

    receive do
      {tag, ^socket, data} when tag in [:tcp, :ssl] ->
        new_buffer = <<buffer::binary, data::binary>>

        if byte_size(new_buffer) > config.max_message_size do
          Logger.warning(
            "MLLP buffer exceeds max_message_size " <>
              "(#{byte_size(new_buffer)} > #{config.max_message_size}), closing connection"
          )

          :telemetry.execute(
            [:hl7v2, :mllp, :message, :exception],
            %{duration: 0},
            %{
              ref: meta.ref,
              peer: meta.peer,
              kind: :error,
              reason: :message_too_large,
              stacktrace: []
            }
          )

          :ok
        else
          {messages, remaining} = HL7v2.MLLP.extract_messages(new_buffer)

          remaining =
            Enum.reduce(messages, remaining, fn message, buf ->
              handle_and_respond(transport, socket, config, meta, message)
              buf
            end)

          loop(transport, socket, config, meta, remaining)
        end

      {closed_tag, ^socket} when closed_tag in [:tcp_closed, :ssl_closed] ->
        :ok

      {error_tag, ^socket, reason} when error_tag in [:tcp_error, :ssl_error] ->
        Logger.warning("MLLP connection error: #{inspect(reason)}")
        :ok
    after
      config.timeout ->
        Logger.debug("MLLP connection timeout after #{config.timeout}ms")
        :ok
    end
  end

  defp handle_and_respond(transport, socket, config, meta, message) do
    msg_start = System.monotonic_time()

    :telemetry.execute(
      [:hl7v2, :mllp, :message, :start],
      %{system_time: System.system_time()},
      %{ref: meta.ref, peer: meta.peer, message_size: byte_size(message)}
    )

    try do
      result = invoke_handler(config.handler, message, meta, config.handler_timeout)

      case result do
        {:ok, response} ->
          framed = HL7v2.MLLP.frame(response)
          transport.send(socket, framed)

          duration = System.monotonic_time() - msg_start

          :telemetry.execute(
            [:hl7v2, :mllp, :message, :stop],
            %{duration: duration},
            %{ref: meta.ref, peer: meta.peer, response_size: byte_size(response)}
          )

        {:error, :handler_timeout} ->
          Logger.warning("MLLP handler timed out after #{config.handler_timeout}ms")

          duration = System.monotonic_time() - msg_start

          :telemetry.execute(
            [:hl7v2, :mllp, :message, :exception],
            %{duration: duration},
            %{
              ref: meta.ref,
              peer: meta.peer,
              kind: :error,
              reason: :handler_timeout,
              stacktrace: []
            }
          )

        {:error, reason} ->
          Logger.warning("MLLP handler error: #{inspect(reason)}")

          duration = System.monotonic_time() - msg_start

          :telemetry.execute(
            [:hl7v2, :mllp, :message, :exception],
            %{duration: duration},
            %{
              ref: meta.ref,
              peer: meta.peer,
              kind: :error,
              reason: reason,
              stacktrace: []
            }
          )
      end
    rescue
      e ->
        duration = System.monotonic_time() - msg_start

        :telemetry.execute(
          [:hl7v2, :mllp, :message, :exception],
          %{duration: duration},
          %{
            ref: meta.ref,
            peer: meta.peer,
            kind: :error,
            reason: e,
            stacktrace: __STACKTRACE__
          }
        )

        Logger.error("MLLP handler raised: #{inspect(e)}")
    end
  end

  # Runs the handler in a separate process with a timeout guard.
  # Uses spawn_monitor (not Task.async) to avoid linking — a handler crash
  # is caught via the DOWN message, not propagated to the connection process.
  defp invoke_handler(handler, message, meta, handler_timeout) do
    parent = self()
    ref = make_ref()

    {pid, mon} =
      spawn_monitor(fn ->
        send(parent, {ref, handler.handle_message(message, meta)})
      end)

    receive do
      {^ref, result} ->
        Process.demonitor(mon, [:flush])
        result

      {:DOWN, ^mon, :process, ^pid, reason} ->
        {:error, {:handler_crash, reason}}
    after
      handler_timeout ->
        Process.demonitor(mon, [:flush])
        Process.exit(pid, :kill)

        # Flush any result that arrived between timeout and kill
        receive do
          {^ref, result} -> result
        after
          0 -> {:error, :handler_timeout}
        end
    end
  end

  defp peer_info(transport, socket) do
    case transport.peername(socket) do
      {:ok, peer} -> peer
      {:error, _} -> {{0, 0, 0, 0}, 0}
    end
  end
end
