defmodule HL7v2.MLLP.PeerCertTest do
  use ExUnit.Case, async: true

  alias HL7v2.MLLP.{Client, Listener}

  @sample "MSH|^~\\&|SEND|FAC|RECV|FAC|20260101000000||ADT^A01|MSG00001|P|2.5\rEVN|A01|20260101000000\r"

  # Hands the handler meta back to the test process carried in handler_state.
  defmodule CapturingHandler do
    @behaviour HL7v2.MLLP.Handler

    @impl true
    def handle_message(_message, %{handler_state: test_pid} = meta) do
      send(test_pid, {:meta, meta})

      {:ok,
       "MSH|^~\\&|RECV|FAC|SEND|FAC|20260101000000||ACK^A01|ACK00001|P|2.5\rMSA|AA|MSG00001\r"}
    end
  end

  describe "handler meta :peer_cert" do
    test "carries the client certificate DER on a mutual-TLS connection" do
      %{server: server_tls, client: client_tls, client_cert: client_cert} = tls_configs()

      {:ok, listener} =
        Listener.start_link(
          port: 0,
          handler: CapturingHandler,
          handler_state: self(),
          tls: server_tls
        )

      port = Listener.port(listener)

      {:ok, client} = Client.start_link(host: "localhost", port: port, tls: client_tls)
      assert {:ok, _ack} = Client.send_message(client, @sample, timeout: 5_000)
      Client.close(client)

      assert_receive {:meta, %{peer_cert: der}}
      assert der == client_cert

      Listener.stop(listener)
    end

    test "is nil on a plain TCP connection" do
      {:ok, listener} =
        Listener.start_link(port: 0, handler: CapturingHandler, handler_state: self())

      port = Listener.port(listener)

      {:ok, client} = Client.start_link(host: "localhost", port: port)
      assert {:ok, _ack} = Client.send_message(client, @sample, timeout: 5_000)
      Client.close(client)

      assert_receive {:meta, %{peer_cert: nil}}

      Listener.stop(listener)
    end
  end

  # In-memory test chains from OTP itself (no fixtures, no extra deps):
  # a server chain and a client chain, each with its own root, so the server
  # verifies the client against the client root and vice versa. RSA keys:
  # the EC defaults fail the TLS 1.3 handshake on recent OTP
  # (`unable_to_supply_acceptable_cert`).
  defp tls_configs do
    rsa = {:rsa, 2048, 17}

    data =
      :public_key.pkix_test_data(%{
        server_chain: %{
          root: [key: rsa],
          intermediates: [],
          peer: [
            key: rsa,
            extensions: [{:Extension, {2, 5, 29, 17}, false, [dNSName: ~c"localhost"]}]
          ]
        },
        client_chain: %{root: [key: rsa], intermediates: [], peer: [key: rsa]}
      })

    server_config = Map.fetch!(data, :server_config)
    client_config = Map.fetch!(data, :client_config)

    %{
      server:
        server_config ++
          [verify: :verify_peer, fail_if_no_peer_cert: true, versions: [:"tlsv1.2", :"tlsv1.3"]],
      client:
        client_config ++
          [
            verify: :verify_peer,
            server_name_indication: ~c"localhost",
            versions: [:"tlsv1.2", :"tlsv1.3"]
          ],
      client_cert: Keyword.fetch!(client_config, :cert)
    }
  end
end
