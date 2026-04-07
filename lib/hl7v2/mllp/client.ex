defmodule HL7v2.MLLP.Client do
  @moduledoc """
  MLLP TCP client for sending HL7v2 messages.

  Maintains a persistent TCP connection and provides synchronous
  send-and-receive for HL7v2 messages over MLLP.

  ## Examples

      {:ok, client} = HL7v2.MLLP.Client.start_link(host: "localhost", port: 2575)

      {:ok, ack} = HL7v2.MLLP.Client.send_message(client, hl7_message)

      :ok = HL7v2.MLLP.Client.close(client)

  ## TLS

      {:ok, client} = HL7v2.MLLP.Client.start_link(
        host: "remote.host",
        port: 2576,
        tls: [verify: :verify_peer, cacertfile: "ca.pem"]
      )

  """

  use GenServer

  @default_timeout 30_000
  @default_max_message_size 10_485_760

  @doc """
  Starts a client connection.

  ## Options

  - `:host` (required) — hostname or IP address to connect to.
  - `:port` (required) — TCP port to connect to.
  - `:timeout` — send/receive timeout in milliseconds (default: `30_000`).
  - `:max_message_size` — maximum response size in bytes (default: `10_485_760` — 10 MB).
    Returns `{:error, :message_too_large}` if the response buffer exceeds this limit.
  - `:tls` — keyword list of `:ssl` options. When present, connects via TLS.

  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @doc """
  Sends an HL7v2 message and waits for the response.

  The message is MLLP-framed before sending. The response is returned
  with MLLP framing stripped.

  ## Options

  - `:timeout` — override the default timeout for this call.

  """
  @spec send_message(GenServer.server(), binary(), keyword()) ::
          {:ok, binary()} | {:error, term()}
  def send_message(client, message, opts \\ []) do
    timeout = Keyword.get(opts, :timeout, @default_timeout)
    GenServer.call(client, {:send, message, timeout}, timeout + 5_000)
  end

  @doc """
  Closes the client connection.
  """
  @spec close(GenServer.server()) :: :ok
  def close(client) do
    GenServer.stop(client)
  end

  # -- Callbacks --

  @impl GenServer
  def init(opts) do
    host = Keyword.fetch!(opts, :host)
    port = Keyword.fetch!(opts, :port)
    timeout = Keyword.get(opts, :timeout, @default_timeout)
    max_message_size = Keyword.get(opts, :max_message_size, @default_max_message_size)
    tls_opts = Keyword.get(opts, :tls)

    host_charlist = host_to_charlist(host)

    case connect(host_charlist, port, tls_opts, timeout) do
      {:ok, socket, transport} ->
        {:ok,
         %{
           socket: socket,
           transport: transport,
           timeout: timeout,
           max_message_size: max_message_size,
           buffer: <<>>
         }}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl GenServer
  def handle_call({:send, message, timeout}, _from, state) do
    %{socket: socket, transport: transport} = state
    framed = HL7v2.MLLP.frame(message)

    case transport_send(transport, socket, framed) do
      :ok ->
        case recv_response(transport, socket, state.buffer, timeout, state.max_message_size) do
          {:ok, response, remaining} ->
            {:reply, {:ok, response}, %{state | buffer: remaining}}

          {:error, reason} ->
            {:reply, {:error, reason}, state}
        end

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @impl GenServer
  def terminate(_reason, %{socket: socket, transport: transport}) do
    transport_close(transport, socket)
    :ok
  end

  def terminate(_reason, _state), do: :ok

  # -- Private --

  defp connect(host, port, nil, timeout) do
    tcp_opts = [:binary, active: false, packet: :raw]

    case :gen_tcp.connect(host, port, tcp_opts, timeout) do
      {:ok, socket} -> {:ok, socket, :tcp}
      {:error, reason} -> {:error, reason}
    end
  end

  defp connect(host, port, tls_opts, timeout) do
    tcp_opts = [:binary, active: false, packet: :raw]

    with {:ok, tcp_socket} <- :gen_tcp.connect(host, port, tcp_opts, timeout),
         {:ok, ssl_socket} <- :ssl.connect(tcp_socket, tls_opts, timeout) do
      {:ok, ssl_socket, :ssl}
    end
  end

  defp transport_send(:tcp, socket, data), do: :gen_tcp.send(socket, data)
  defp transport_send(:ssl, socket, data), do: :ssl.send(socket, data)

  defp transport_close(:tcp, socket), do: :gen_tcp.close(socket)
  defp transport_close(:ssl, socket), do: :ssl.close(socket)

  defp recv_response(transport, socket, initial_buffer, timeout, max_message_size) do
    # Check if the buffer already contains a complete message from a previous call
    case HL7v2.MLLP.extract_messages(initial_buffer) do
      {[message | rest], remaining} ->
        {:ok, message, rebuffer(rest, remaining)}

      _ ->
        recv_loop(transport, socket, initial_buffer, timeout, max_message_size)
    end
  end

  defp recv_loop(transport, socket, buffer, timeout, max_message_size) do
    case transport_recv(transport, socket, 0, timeout) do
      {:ok, data} ->
        new_buffer = <<buffer::binary, data::binary>>

        if byte_size(new_buffer) > max_message_size do
          {:error, :message_too_large}
        else
          case HL7v2.MLLP.extract_messages(new_buffer) do
            {[message | rest], remaining} ->
              {:ok, message, rebuffer(rest, remaining)}

            {[], _remaining} ->
              recv_loop(transport, socket, new_buffer, timeout, max_message_size)
          end
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp transport_recv(:tcp, socket, length, timeout) do
    :gen_tcp.recv(socket, length, timeout)
  end

  defp transport_recv(:ssl, socket, length, timeout) do
    :ssl.recv(socket, length, timeout)
  end

  defp host_to_charlist(host) when is_binary(host), do: String.to_charlist(host)
  defp host_to_charlist(host) when is_list(host), do: host
  defp host_to_charlist(host) when is_atom(host), do: Atom.to_charlist(host)

  # Re-frame unconsumed extracted messages back into the raw buffer so they
  # are available on the next send_message call.
  defp rebuffer([], remaining), do: remaining

  defp rebuffer(extra_messages, remaining) do
    reframed = extra_messages |> Enum.map(&HL7v2.MLLP.frame/1) |> IO.iodata_to_binary()
    <<reframed::binary, remaining::binary>>
  end
end
