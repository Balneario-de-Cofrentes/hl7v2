defmodule HL7v2.MLLP.ListenerTest do
  use ExUnit.Case, async: true

  alias HL7v2.MLLP.{Client, Listener}

  @sb 0x0B
  @eb 0x1C
  @cr 0x0D

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

    %{listener: listener, port: port}
  end

  test "accepts connection and echoes message", %{port: port} do
    {:ok, client} = Client.start_link(host: "127.0.0.1", port: port)

    assert {:ok, "hello"} = Client.send_message(client, "hello")

    Client.close(client)
  end

  test "handles HL7 message", %{port: port} do
    msg = "MSH|^~\\&|SEND|FAC||RCV||20240101||ADT^A01|123|P|2.5\r"

    {:ok, client} = Client.start_link(host: "127.0.0.1", port: port)

    assert {:ok, ^msg} = Client.send_message(client, msg)

    Client.close(client)
  end

  test "handles multiple messages on same connection", %{port: port} do
    {:ok, client} = Client.start_link(host: "127.0.0.1", port: port)

    assert {:ok, "first"} = Client.send_message(client, "first")
    assert {:ok, "second"} = Client.send_message(client, "second")
    assert {:ok, "third"} = Client.send_message(client, "third")

    Client.close(client)
  end

  test "handler callback receives the message", %{port: port} do
    # The echo handler returns exactly what it receives — verifying
    # that the raw HL7 message (no MLLP framing) reaches the handler.
    message = "MSH|^~\\&|TEST|||||||ADT^A01|1|P|2.5\r"

    {:ok, client} = Client.start_link(host: "127.0.0.1", port: port)

    assert {:ok, ^message} = Client.send_message(client, message)

    Client.close(client)
  end

  test "listener stop cleans up", %{listener: listener, port: port} do
    Listener.stop(listener)
    Process.flag(:trap_exit, true)

    # Attempting to connect after stop should fail
    assert {:error, _} = Client.start_link(host: "127.0.0.1", port: port)
  end

  test "multiple concurrent clients", %{port: port} do
    tasks =
      for i <- 1..5 do
        Task.async(fn ->
          {:ok, client} = Client.start_link(host: "127.0.0.1", port: port)
          msg = "message_#{i}"
          {:ok, response} = Client.send_message(client, msg)
          Client.close(client)
          {msg, response}
        end)
      end

    results = Task.await_many(tasks, 10_000)

    for {sent, received} <- results do
      assert sent == received
    end
  end

  test "raw TCP client receives proper MLLP frame", %{port: port} do
    {:ok, socket} = :gen_tcp.connect(~c"127.0.0.1", port, [:binary, active: false])

    # Send a properly framed message
    :gen_tcp.send(socket, <<@sb, "test", @eb, @cr>>)

    # Should receive a properly framed response
    {:ok, data} = :gen_tcp.recv(socket, 0, 5_000)
    assert <<@sb, "test", @eb, @cr>> == data

    :gen_tcp.close(socket)
  end
end
