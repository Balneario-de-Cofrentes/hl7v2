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

  - `[:hl7v2, :mllp, :message, :exception]` — emitted when handler raises
    - Measurements: `%{duration: integer()}`
    - Metadata: `%{ref: term(), peer: {address, port}, kind: term(), reason: term(), stacktrace: list()}`

  """

  @behaviour :ranch_protocol

  require Logger

  @default_timeout 60_000

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

    peer = peer_info(transport, socket)
    conn_start = System.monotonic_time()

    :telemetry.execute(
      [:hl7v2, :mllp, :connection, :start],
      %{system_time: System.system_time()},
      %{ref: ref, peer: peer}
    )

    meta = %{peer: peer, ref: ref, handler_state: handler_state}

    try do
      loop(transport, socket, handler, meta, timeout, <<>>)
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

  defp loop(transport, socket, handler, meta, timeout, buffer) do
    transport.setopts(socket, active: :once)

    receive do
      {tag, ^socket, data} when tag in [:tcp, :ssl] ->
        new_buffer = <<buffer::binary, data::binary>>
        {messages, remaining} = HL7v2.MLLP.extract_messages(new_buffer)

        remaining =
          Enum.reduce(messages, remaining, fn message, buf ->
            handle_and_respond(transport, socket, handler, meta, message)
            buf
          end)

        loop(transport, socket, handler, meta, timeout, remaining)

      {closed_tag, ^socket} when closed_tag in [:tcp_closed, :ssl_closed] ->
        :ok

      {error_tag, ^socket, reason} when error_tag in [:tcp_error, :ssl_error] ->
        Logger.warning("MLLP connection error: #{inspect(reason)}")
        :ok
    after
      timeout ->
        Logger.debug("MLLP connection timeout after #{timeout}ms")
        :ok
    end
  end

  defp handle_and_respond(transport, socket, handler, meta, message) do
    msg_start = System.monotonic_time()

    :telemetry.execute(
      [:hl7v2, :mllp, :message, :start],
      %{system_time: System.system_time()},
      %{ref: meta.ref, peer: meta.peer, message_size: byte_size(message)}
    )

    try do
      case handler.handle_message(message, meta) do
        {:ok, response} ->
          framed = HL7v2.MLLP.frame(response)
          transport.send(socket, framed)

          duration = System.monotonic_time() - msg_start

          :telemetry.execute(
            [:hl7v2, :mllp, :message, :stop],
            %{duration: duration},
            %{ref: meta.ref, peer: meta.peer, response_size: byte_size(response)}
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

  defp peer_info(transport, socket) do
    case transport.peername(socket) do
      {:ok, peer} -> peer
      {:error, _} -> {{0, 0, 0, 0}, 0}
    end
  end
end
