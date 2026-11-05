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

  ## Logging

  Log lines never carry the raw error term. A TLS error from `:ssl` can embed
  the peer certificate subject, and a handler exception can embed message
  content, so the connection logs a closed set of tags instead: the atom
  reason, `{:tls_alert, alert_type}`, the exception module, or
  `{:handler_crash, ExceptionModule | :throw}` (Erlang error terms are
  normalised to their Elixir module, e.g. `MatchError`). The raw term is still
  returned and still reaches the telemetry metadata above, for consumers that
  run in-process and can redact it themselves.

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

    peer_cert = peer_cert(transport, socket)
    meta = %{peer: peer, peer_cert: peer_cert, ref: ref, handler_state: handler_state}

    config = %{
      handler: handler,
      timeout: timeout,
      max_message_size: max_message_size,
      handler_timeout: handler_timeout
    }

    reason =
      try do
        loop(transport, socket, config, meta, <<>>)
      catch
        kind, value -> {:crash, kind, value}
      end

    duration = System.monotonic_time() - conn_start

    stop_reason =
      case reason do
        :normal -> :normal
        :closed -> :closed
        :timeout -> :timeout
        :message_too_large -> :message_too_large
        {:error, err} -> {:error, err}
        {:crash, _, _} -> :crash
        other -> other
      end

    :telemetry.execute(
      [:hl7v2, :mllp, :connection, :stop],
      %{duration: duration},
      %{ref: ref, peer: peer, reason: stop_reason}
    )

    transport.close(socket)
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

          :message_too_large
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
        :closed

      {error_tag, ^socket, reason} when error_tag in [:tcp_error, :ssl_error] ->
        Logger.warning("MLLP connection error: #{inspect(log_tag(reason))}")
        {:error, reason}
    after
      config.timeout ->
        Logger.debug("MLLP connection timeout after #{config.timeout}ms")
        :timeout
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
          Logger.warning("MLLP handler error: #{inspect(log_tag(reason))}")

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

        Logger.error("MLLP handler raised: #{inspect(log_tag(e))}")
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
        send(parent, {ref, safe_handle(handler, message, meta)})
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

  # Catches whatever the handler raises, throws or exits with, so the handler
  # process ends normally and the runtime emits no crash report (which would
  # print the exception — and with it any message content it carries — at
  # error level). The result is the same `{:handler_crash, exit_reason}` the
  # DOWN branch above produces for an uncaught exit, so callers see one shape.
  defp safe_handle(handler, message, meta) do
    handler.handle_message(message, meta)
  catch
    :exit, reason -> {:error, {:handler_crash, reason}}
    :throw, value -> {:error, {:handler_crash, {{:nocatch, value}, __STACKTRACE__}}}
    :error, reason -> {:error, {:handler_crash, {reason, __STACKTRACE__}}}
  end

  # The closed set of tags that may appear in a log line. The raw term stays
  # in the return value and in the telemetry metadata; it never reaches a log.
  # A crash keeps its exception module so an operator can tell a parser crash
  # from a timeout without seeing the message or the stack frames.
  # The alert type is a fixed OTP atom (:unknown_ca, :certificate_expired,
  # ...) with no peer data in it; the text next to it names the peer
  # certificate in prose and is dropped.
  defp log_tag({:tls_alert, {alert, _text}}) when is_atom(alert), do: {:tls_alert, alert}
  defp log_tag({:tls_alert, _}), do: :tls_alert
  defp log_tag({:handler_crash, {{:nocatch, _}, _stacktrace}}), do: {:handler_crash, :throw}

  # Exception structs come back unchanged; Erlang error terms (:badarg,
  # {:badmatch, term}, :function_clause) get their Elixir module without the
  # term itself reaching the log.
  defp log_tag({:handler_crash, {reason, stacktrace}}) when is_list(stacktrace),
    do: {:handler_crash, Exception.normalize(:error, reason, stacktrace).__struct__}

  defp log_tag({:handler_crash, _}), do: :handler_crash
  defp log_tag(%{__struct__: module}), do: module
  defp log_tag(reason) when is_atom(reason), do: reason
  defp log_tag(_other), do: :other

  defp peer_info(transport, socket) do
    case transport.peername(socket) do
      {:ok, peer} -> peer
      {:error, _} -> {{0, 0, 0, 0}, 0}
    end
  end

  # The client certificate (DER) on TLS connections, so handlers can tell
  # mutual-TLS clients apart. `:ranch_ssl` hands us a plain `:ssl` socket.
  defp peer_cert(:ranch_ssl, socket) do
    case :ssl.peercert(socket) do
      {:ok, der} when is_binary(der) -> der
      {:error, _} -> nil
    end
  end

  defp peer_cert(_transport, _socket), do: nil
end
