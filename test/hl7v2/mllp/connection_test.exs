defmodule HL7v2.MLLP.ConnectionTest do
  use ExUnit.Case, async: true

  alias HL7v2.MLLP.{Client, Listener}

  @sb 0x0B
  @eb 0x1C
  @cr 0x0D

  describe "handler returning {:error, reason}" do
    setup do
      {:ok, listener} =
        Listener.start_link(
          port: 0,
          handler: HL7v2.Test.ErrorHandler
        )

      port = Listener.port(listener)

      on_exit(fn ->
        try do
          if Process.alive?(listener), do: Listener.stop(listener)
        catch
          :exit, _ -> :ok
        end
      end)

      %{port: port}
    end

    test "handles error response gracefully", %{port: port} do
      {:ok, socket} = :gen_tcp.connect(~c"127.0.0.1", port, [:binary, active: false])

      # Send "error" message which triggers {:error, :test_error} from handler
      :gen_tcp.send(socket, <<@sb, "error", @eb, @cr>>)

      # The connection should NOT send back a response when handler returns error,
      # but it should stay alive for more messages
      Process.sleep(50)

      # Send a normal message to verify the connection is still alive
      :gen_tcp.send(socket, <<@sb, "hello", @eb, @cr>>)
      {:ok, data} = :gen_tcp.recv(socket, 0, 5_000)
      assert <<@sb, "hello", @eb, @cr>> == data

      :gen_tcp.close(socket)
    end

    test "handles handler exception gracefully", %{port: port} do
      {:ok, socket} = :gen_tcp.connect(~c"127.0.0.1", port, [:binary, active: false])

      # Send "raise" message which triggers a RuntimeError in the handler
      :gen_tcp.send(socket, <<@sb, "raise", @eb, @cr>>)

      # The connection should catch the exception and stay alive
      Process.sleep(50)

      # Send a normal message to verify the connection is still alive
      :gen_tcp.send(socket, <<@sb, "ok", @eb, @cr>>)
      {:ok, data} = :gen_tcp.recv(socket, 0, 5_000)
      assert <<@sb, "ok", @eb, @cr>> == data

      :gen_tcp.close(socket)
    end
  end

  describe "telemetry events" do
    setup do
      ref = make_ref()
      handler_id = "conn-telemetry-#{inspect(ref)}"

      :telemetry.attach_many(
        handler_id,
        [
          [:hl7v2, :mllp, :connection, :start],
          [:hl7v2, :mllp, :connection, :stop],
          [:hl7v2, :mllp, :message, :start],
          [:hl7v2, :mllp, :message, :stop],
          [:hl7v2, :mllp, :message, :exception]
        ],
        fn event, measurements, metadata, %{pid: pid, ref: ref} ->
          send(pid, {ref, event, measurements, metadata})
        end,
        %{pid: self(), ref: ref}
      )

      {:ok, listener} =
        Listener.start_link(
          port: 0,
          handler: HL7v2.Test.ErrorHandler
        )

      port = Listener.port(listener)

      on_exit(fn ->
        :telemetry.detach(handler_id)

        try do
          if Process.alive?(listener), do: Listener.stop(listener)
        catch
          :exit, _ -> :ok
        end
      end)

      %{port: port, ref: ref}
    end

    test "emits connection start/stop events", %{port: port, ref: ref} do
      {:ok, client} = Client.start_link(host: "127.0.0.1", port: port)
      Client.send_message(client, "test")
      Client.close(client)

      # Give time for telemetry events
      Process.sleep(50)

      assert_receive {^ref, [:hl7v2, :mllp, :connection, :start], %{system_time: _}, _}
    end

    test "emits message start/stop events on success", %{port: port, ref: ref} do
      {:ok, client} = Client.start_link(host: "127.0.0.1", port: port)
      {:ok, _} = Client.send_message(client, "test")
      Client.close(client)

      assert_receive {^ref, [:hl7v2, :mllp, :message, :start], %{system_time: _},
                      %{message_size: 4}}

      assert_receive {^ref, [:hl7v2, :mllp, :message, :stop], %{duration: _}, %{response_size: 4}}
    end

    test "emits message exception event on handler error", %{port: port, ref: ref} do
      {:ok, socket} = :gen_tcp.connect(~c"127.0.0.1", port, [:binary, active: false])
      :gen_tcp.send(socket, <<@sb, "error", @eb, @cr>>)
      Process.sleep(100)
      :gen_tcp.close(socket)

      assert_receive {^ref, [:hl7v2, :mllp, :message, :exception], %{duration: _},
                      %{kind: :error, reason: :test_error}}, 500
    end

    test "emits message exception event on handler raise", %{port: port, ref: ref} do
      {:ok, socket} = :gen_tcp.connect(~c"127.0.0.1", port, [:binary, active: false])
      :gen_tcp.send(socket, <<@sb, "raise", @eb, @cr>>)
      Process.sleep(100)
      :gen_tcp.close(socket)

      assert_receive {^ref, [:hl7v2, :mllp, :message, :exception], %{duration: _},
                      %{
                        kind: :error,
                        reason: {:handler_crash, {%RuntimeError{}, _}},
                        stacktrace: _
                      }}, 500
    end
  end

  describe "max_message_size" do
    test "closes connection when buffer exceeds max_message_size" do
      {:ok, listener} =
        Listener.start_link(
          port: 0,
          handler: HL7v2.Test.EchoHandler,
          max_message_size: 64
        )

      port = Listener.port(listener)

      on_exit(fn ->
        try do
          if Process.alive?(listener), do: Listener.stop(listener)
        catch
          :exit, _ -> :ok
        end
      end)

      {:ok, socket} = :gen_tcp.connect(~c"127.0.0.1", port, [:binary, active: false])

      # Send a message larger than 64 bytes (without completing the MLLP frame
      # so the buffer keeps growing)
      big_payload = :binary.copy("X", 100)
      :gen_tcp.send(socket, <<@sb, big_payload::binary>>)

      # The server should close the connection
      assert {:error, :closed} = :gen_tcp.recv(socket, 0, 2_000)

      :gen_tcp.close(socket)
    end

    test "accepts messages under max_message_size" do
      {:ok, listener} =
        Listener.start_link(
          port: 0,
          handler: HL7v2.Test.EchoHandler,
          max_message_size: 1024
        )

      port = Listener.port(listener)

      on_exit(fn ->
        try do
          if Process.alive?(listener), do: Listener.stop(listener)
        catch
          :exit, _ -> :ok
        end
      end)

      {:ok, client} = Client.start_link(host: "127.0.0.1", port: port)
      {:ok, response} = Client.send_message(client, "small")
      assert response == "small"

      Client.close(client)
    end
  end

  describe "handler_timeout" do
    test "kills handler after handler_timeout and continues accepting messages" do
      {:ok, listener} =
        Listener.start_link(
          port: 0,
          handler: HL7v2.Test.SlowHandler,
          handler_timeout: 100
        )

      port = Listener.port(listener)

      on_exit(fn ->
        try do
          if Process.alive?(listener), do: Listener.stop(listener)
        catch
          :exit, _ -> :ok
        end
      end)

      {:ok, socket} = :gen_tcp.connect(~c"127.0.0.1", port, [:binary, active: false])

      # Send "slow" which sleeps forever in the handler
      :gen_tcp.send(socket, <<@sb, "slow", @eb, @cr>>)

      # No response should come (handler timed out), but connection stays alive
      assert {:error, :timeout} = :gen_tcp.recv(socket, 0, 300)

      # Send a normal message to verify the connection still works
      :gen_tcp.send(socket, <<@sb, "hello", @eb, @cr>>)
      {:ok, data} = :gen_tcp.recv(socket, 0, 5_000)
      assert <<@sb, "hello", @eb, @cr>> == data

      :gen_tcp.close(socket)
    end

    test "emits telemetry on handler timeout" do
      ref = make_ref()
      handler_id = "timeout-telemetry-#{inspect(ref)}"

      :telemetry.attach_many(
        handler_id,
        [[:hl7v2, :mllp, :message, :exception]],
        fn event, measurements, metadata, %{pid: pid, ref: ref} ->
          send(pid, {ref, event, measurements, metadata})
        end,
        %{pid: self(), ref: ref}
      )

      {:ok, listener} =
        Listener.start_link(
          port: 0,
          handler: HL7v2.Test.SlowHandler,
          handler_timeout: 100
        )

      port = Listener.port(listener)

      on_exit(fn ->
        :telemetry.detach(handler_id)

        try do
          if Process.alive?(listener), do: Listener.stop(listener)
        catch
          :exit, _ -> :ok
        end
      end)

      {:ok, socket} = :gen_tcp.connect(~c"127.0.0.1", port, [:binary, active: false])
      :gen_tcp.send(socket, <<@sb, "slow", @eb, @cr>>)

      assert_receive {^ref, [:hl7v2, :mllp, :message, :exception], %{duration: _},
                      %{kind: :error, reason: :handler_timeout}},
                     1_000

      :gen_tcp.close(socket)
    end
  end

  describe "client max_message_size" do
    test "returns error when response exceeds client max_message_size" do
      {:ok, listener} =
        Listener.start_link(
          port: 0,
          handler: HL7v2.Test.EchoHandler
        )

      port = Listener.port(listener)

      on_exit(fn ->
        try do
          if Process.alive?(listener), do: Listener.stop(listener)
        catch
          :exit, _ -> :ok
        end
      end)

      # Client with tiny max — the echoed response will exceed it
      {:ok, client} = Client.start_link(host: "127.0.0.1", port: port, max_message_size: 4)
      result = Client.send_message(client, "this message is way too long for the limit")
      assert {:error, :message_too_large} = result

      Client.close(client)
    end
  end

  describe "handler_state" do
    test "passes handler_state through meta" do
      test_pid = self()

      handler_mod =
        Module.concat(HL7v2.Test, :"StateCheckHandler#{System.unique_integer([:positive])}")

      Module.create(
        handler_mod,
        quote do
          @behaviour HL7v2.MLLP.Handler
          @impl true
          def handle_message(message, meta) do
            send(unquote(Macro.escape(test_pid)), {:handler_state, meta.handler_state})
            {:ok, message}
          end
        end,
        Macro.Env.location(__ENV__)
      )

      {:ok, listener} =
        Listener.start_link(
          port: 0,
          handler: handler_mod,
          handler_state: %{custom: "data"}
        )

      port = Listener.port(listener)

      {:ok, client} = Client.start_link(host: "127.0.0.1", port: port)
      {:ok, _} = Client.send_message(client, "test")

      assert_receive {:handler_state, %{custom: "data"}}

      Client.close(client)
      Listener.stop(listener)
    end
  end
end
