defmodule HL7v2.MLLP.Listener do
  @moduledoc """
  MLLP TCP listener using Ranch 2.x.

  Starts a TCP (or TLS) listener that accepts MLLP connections and dispatches
  messages to the configured handler module.

  ## Options

  - `:port` (required) — TCP port to listen on. Use `0` for OS-assigned port.
  - `:handler` (required) — module implementing `HL7v2.MLLP.Handler`.
  - `:handler_state` — arbitrary term passed to the handler in metadata.
  - `:ref` — Ranch listener reference (default: auto-generated atom).
  - `:num_acceptors` — number of acceptor processes (default: `10`).
  - `:tls` — keyword list of TLS options. When present, Ranch uses `:ranch_ssl`
    instead of `:ranch_tcp`. See `HL7v2.MLLP.TLS` for helpers.
  - `:timeout` — idle connection timeout in milliseconds (default: `60_000`).

  ## Examples

      {:ok, pid} = HL7v2.MLLP.Listener.start_link(
        port: 2575,
        handler: MyHandler
      )

      # Get the assigned port (useful when port: 0)
      port = HL7v2.MLLP.Listener.port(pid)

      # Stop the listener
      HL7v2.MLLP.Listener.stop(pid)

  """

  use GenServer

  @default_num_acceptors 10
  @default_timeout 60_000

  @doc """
  Starts an MLLP listener.

  See module documentation for available options.
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @doc """
  Returns the port the listener is bound to.

  Useful when the listener was started with `port: 0` for OS-assigned ports.
  """
  @spec port(GenServer.server()) :: :inet.port_number()
  def port(server) do
    GenServer.call(server, :port)
  end

  @doc """
  Stops an MLLP listener.
  """
  @spec stop(GenServer.server()) :: :ok
  def stop(server) do
    GenServer.stop(server)
  end

  # -- Callbacks --

  @impl GenServer
  def init(opts) do
    port = Keyword.fetch!(opts, :port)
    handler = Keyword.fetch!(opts, :handler)
    handler_state = Keyword.get(opts, :handler_state)
    num_acceptors = Keyword.get(opts, :num_acceptors, @default_num_acceptors)
    timeout = Keyword.get(opts, :timeout, @default_timeout)
    tls_opts = Keyword.get(opts, :tls)
    ref = Keyword.get(opts, :ref, make_ref())

    {transport, socket_opts} = transport_config(port, tls_opts)

    trans_opts = %{
      socket_opts: socket_opts,
      num_acceptors: num_acceptors
    }

    proto_opts = [
      handler: handler,
      handler_state: handler_state,
      timeout: timeout
    ]

    case :ranch.start_listener(ref, transport, trans_opts, HL7v2.MLLP.Connection, proto_opts) do
      {:ok, _pid} ->
        {:ok, %{ref: ref}}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl GenServer
  def handle_call(:port, _from, %{ref: ref} = state) do
    {:reply, :ranch.get_port(ref), state}
  end

  @impl GenServer
  def terminate(_reason, %{ref: ref}) do
    :ranch.stop_listener(ref)
    :ok
  end

  defp transport_config(port, nil) do
    {:ranch_tcp, [port: port]}
  end

  defp transport_config(port, tls_opts) when is_list(tls_opts) do
    {:ranch_ssl, [port: port] ++ tls_opts}
  end
end
