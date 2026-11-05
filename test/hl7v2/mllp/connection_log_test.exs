defmodule HL7v2.MLLP.ConnectionLogTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  alias HL7v2.MLLP.Listener

  @sb 0x0B
  @eb 0x1C
  @cr 0x0D

  # The strings `HL7v2.Test.ErrorHandler` raises and throws with. They stand
  # in for message content a real handler exception could carry (a failed
  # parse quotes the segment it choked on), so no log line may contain them.
  @raise_marker "handler_exploded"
  @throw_marker "handler_threw"

  setup :start_listener

  describe "handler crash" do
    test "logs the exception module and never the exception", %{port: port} do
      socket = connect!(port)

      log =
        capture_log(fn ->
          :gen_tcp.send(socket, frame("raise"))
          # The connection logs before it goes back to reading, so once the
          # next message is echoed the log line is in.
          assert_echo(socket, "ok")
          # Leave time for a runtime crash report, should one be emitted.
          Process.sleep(50)
        end)

      assert log =~ "MLLP handler error: {:handler_crash, RuntimeError}"
      refute log =~ @raise_marker
      refute log =~ "raised an exception"
    end

    test "logs :throw and never the thrown value", %{port: port} do
      socket = connect!(port)

      log =
        capture_log(fn ->
          :gen_tcp.send(socket, frame("throw"))
          assert_echo(socket, "ok")
          Process.sleep(50)
        end)

      assert log =~ "MLLP handler error: {:handler_crash, :throw}"
      refute log =~ @throw_marker
    end

    test "keeps the exit reason shape in the telemetry metadata", %{port: port} do
      ref = make_ref()
      handler_id = "conn-log-telemetry-#{inspect(ref)}"

      :telemetry.attach(
        handler_id,
        [:hl7v2, :mllp, :message, :exception],
        &__MODULE__.handle_telemetry_event/4,
        %{pid: self(), ref: ref}
      )

      on_exit(fn -> :telemetry.detach(handler_id) end)

      socket = connect!(port)
      :gen_tcp.send(socket, frame("raise"))
      assert_echo(socket, "ok")

      assert_receive {^ref, [:hl7v2, :mllp, :message, :exception], _,
                      %{
                        kind: :error,
                        reason: {:handler_crash, {%RuntimeError{message: message}, stacktrace}}
                      }}

      assert message == @raise_marker
      assert is_list(stacktrace)
    end
  end

  describe "connection error" do
    test "logs :tls_alert and never the alert text", %{port: port, ref: ref} do
      socket = connect!(port)
      # One round trip guarantees the connection process is up and reading.
      assert_echo(socket, "hello")

      [conn] = :ranch.procs(ref, :connections)
      {:links, links} = Process.info(conn, :links)
      [server_socket] = Enum.filter(links, &is_port/1)

      # What `:ssl` reports after a failed certificate check: the alert text
      # names the peer certificate (subject, issuer) in prose.
      alert =
        {:tls_alert,
         {:unknown_ca,
          ~c"TLS server: In state certify at ssl_handshake.erl:2213 generated SERVER ALERT: " ++
            ~c"Fatal - Unknown CA (CN=secret-partner,O=Hospital)"}}

      log =
        capture_log(fn ->
          send(conn, {:ssl_error, server_socket, alert})
          # The connection logs, then closes the socket.
          assert {:error, :closed} = :gen_tcp.recv(socket, 0, 2_000)
        end)

      assert log =~ "MLLP connection error: :tls_alert"
      refute log =~ "unknown_ca"
      refute log =~ "secret-partner"
    end
  end

  # Named handler function to avoid telemetry "local function" warnings.
  def handle_telemetry_event(event, measurements, metadata, %{pid: pid, ref: ref}) do
    send(pid, {ref, event, measurements, metadata})
  end

  # Starts a listener on an ephemeral port with a known Ranch ref (so the test
  # can find the connection process) and stops it when the test exits, even
  # after a failed assertion.
  defp start_listener(_context) do
    ref = make_ref()

    {:ok, listener} =
      Listener.start_link(port: 0, ref: ref, handler: HL7v2.Test.ErrorHandler)

    on_exit(fn ->
      try do
        if Process.alive?(listener), do: Listener.stop(listener)
      catch
        :exit, _ -> :ok
      end
    end)

    %{port: Listener.port(listener), ref: ref}
  end

  defp connect!(port) do
    {:ok, socket} = :gen_tcp.connect(~c"127.0.0.1", port, [:binary, active: false])
    on_exit(fn -> :gen_tcp.close(socket) end)
    socket
  end

  defp frame(message), do: <<@sb, message::binary, @eb, @cr>>

  # Sends a message the handler echoes back and waits for the echo: proves the
  # connection survived whatever came before it.
  defp assert_echo(socket, message) do
    :gen_tcp.send(socket, frame(message))
    assert {:ok, data} = :gen_tcp.recv(socket, 0, 5_000)
    assert data == frame(message)
  end
end
