defmodule HL7v2.MLLP.ClientTest do
  use ExUnit.Case, async: true

  alias HL7v2.MLLP.{Client, Listener}

  setup do
    {:ok, listener} =
      Listener.start_link(
        port: 0,
        handler: HL7v2.Test.EchoHandler
      )

    port = Listener.port(listener)

    on_exit(fn ->
      if Process.alive?(listener), do: Listener.stop(listener)
    end)

    %{port: port}
  end

  test "connect, send, receive", %{port: port} do
    {:ok, client} = Client.start_link(host: "127.0.0.1", port: port)

    assert {:ok, "ping"} = Client.send_message(client, "ping")

    Client.close(client)
  end

  test "send_message with custom timeout", %{port: port} do
    {:ok, client} = Client.start_link(host: "127.0.0.1", port: port)

    assert {:ok, "msg"} = Client.send_message(client, "msg", timeout: 10_000)

    Client.close(client)
  end

  test "connection close stops the GenServer", %{port: port} do
    {:ok, client} = Client.start_link(host: "127.0.0.1", port: port)

    ref = Process.monitor(client)
    Client.close(client)

    assert_receive {:DOWN, ^ref, :process, ^client, :normal}, 5_000
  end

  test "connection refused returns error" do
    Process.flag(:trap_exit, true)

    # Use a port that's very unlikely to be listening
    assert {:error, _reason} = Client.start_link(host: "127.0.0.1", port: 1)
  end

  test "multiple sequential messages", %{port: port} do
    {:ok, client} = Client.start_link(host: "127.0.0.1", port: port)

    for i <- 1..10 do
      msg = "message_#{i}"
      assert {:ok, ^msg} = Client.send_message(client, msg)
    end

    Client.close(client)
  end

  test "large message", %{port: port} do
    {:ok, client} = Client.start_link(host: "127.0.0.1", port: port)

    # 100KB message
    large = String.duplicate("X", 100_000)
    assert {:ok, ^large} = Client.send_message(client, large)

    Client.close(client)
  end

  test "accepts host as charlist", %{port: port} do
    {:ok, client} = Client.start_link(host: ~c"127.0.0.1", port: port)

    assert {:ok, "test"} = Client.send_message(client, "test")

    Client.close(client)
  end

  test "accepts host as atom", %{port: port} do
    {:ok, client} = Client.start_link(host: :localhost, port: port)

    assert {:ok, "test"} = Client.send_message(client, "test")

    Client.close(client)
  end

  test "accepts custom timeout option", %{port: port} do
    {:ok, client} = Client.start_link(host: "127.0.0.1", port: port, timeout: 5_000)

    assert {:ok, "msg"} = Client.send_message(client, "msg")

    Client.close(client)
  end

  @tag capture_log: true
  test "recv error when server closes during receive", %{port: _port} do
    # Start a listener with a very short timeout so it closes connections quickly.
    # Use 1ms timeout + 300ms wait for a 300x margin to eliminate flake.
    {:ok, short_listener} =
      Listener.start_link(
        port: 0,
        handler: HL7v2.Test.EchoHandler,
        timeout: 1
      )

    short_port = Listener.port(short_listener)

    {:ok, client} = Client.start_link(host: "127.0.0.1", port: short_port)

    # Wait well past server timeout for TCP close to propagate
    Process.sleep(300)

    # Sending after server closed should return an error
    result = Client.send_message(client, "test")
    assert {:error, _reason} = result

    Client.close(client)
    Listener.stop(short_listener)
  end

  @tag capture_log: true
  test "protocol desync: stale bytes in buffer trigger error and close", %{port: _port} do
    # Server sends two MLLP frames in response to one request — protocol violation.
    {:ok, listen} = :gen_tcp.listen(0, [:binary, active: false, reuseaddr: true])
    {:ok, tcp_port} = :inet.port(listen)

    spawn_link(fn ->
      {:ok, sock} = :gen_tcp.accept(listen, 5_000)

      {:ok, _data} = recv_mllp_frame(sock)
      ack1 = HL7v2.MLLP.frame("ACK1")
      extra = HL7v2.MLLP.frame("STALE")
      :ok = :gen_tcp.send(sock, <<ack1::binary, extra::binary>>)

      # Keep socket open for the second request attempt
      Process.sleep(1_000)
      :gen_tcp.close(sock)
    end)

    Process.flag(:trap_exit, true)
    {:ok, client} = Client.start_link(host: "127.0.0.1", port: tcp_port)

    # First send_message gets ACK1 — the extra STALE frame stays in buffer
    assert {:ok, "ACK1"} = Client.send_message(client, "req1")

    # Second send_message detects stale buffer → desync error, connection closed
    assert {:error, :protocol_desync} = Client.send_message(client, "req2")

    :gen_tcp.close(listen)
  end

  @tag capture_log: true
  test "protocol desync: partial stale bytes also trigger error", %{port: _port} do
    # Server sends response + partial garbage bytes — protocol violation.
    {:ok, listen} = :gen_tcp.listen(0, [:binary, active: false, reuseaddr: true])
    {:ok, tcp_port} = :inet.port(listen)

    spawn_link(fn ->
      {:ok, sock} = :gen_tcp.accept(listen, 5_000)

      {:ok, _data} = recv_mllp_frame(sock)
      ack = HL7v2.MLLP.frame("ACK1")
      # Partial frame: start byte + content but no end byte
      partial = <<0x0B, "BROKEN">>
      :ok = :gen_tcp.send(sock, <<ack::binary, partial::binary>>)

      Process.sleep(1_000)
      :gen_tcp.close(sock)
    end)

    Process.flag(:trap_exit, true)
    {:ok, client} = Client.start_link(host: "127.0.0.1", port: tcp_port)

    assert {:ok, "ACK1"} = Client.send_message(client, "req1")

    # Partial bytes in buffer → desync error
    assert {:error, :protocol_desync} = Client.send_message(client, "req2")

    :gen_tcp.close(listen)
  end

  # Helper: read one complete MLLP frame from a raw TCP socket
  defp recv_mllp_frame(sock, buf \\ <<>>) do
    {:ok, data} = :gen_tcp.recv(sock, 0, 5_000)
    buf = <<buf::binary, data::binary>>

    case HL7v2.MLLP.extract_messages(buf) do
      {[msg | _], _} -> {:ok, msg}
      _ -> recv_mllp_frame(sock, buf)
    end
  end
end
