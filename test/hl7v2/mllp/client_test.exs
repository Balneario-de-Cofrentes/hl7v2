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
end
