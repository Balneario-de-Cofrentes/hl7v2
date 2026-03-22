defmodule HL7v2.MLLP.TLSTest do
  use ExUnit.Case, async: true

  alias HL7v2.MLLP.TLS

  describe "server_options/1" do
    test "returns options with defaults" do
      opts = TLS.server_options(certfile: "server.pem", keyfile: "server-key.pem")

      assert opts[:certfile] == "server.pem"
      assert opts[:keyfile] == "server-key.pem"
      assert opts[:versions] == [:"tlsv1.2", :"tlsv1.3"]
    end

    test "allows overriding versions" do
      opts =
        TLS.server_options(
          certfile: "server.pem",
          keyfile: "server-key.pem",
          versions: [:"tlsv1.3"]
        )

      assert opts[:versions] == [:"tlsv1.3"]
    end

    test "passes through extra options" do
      opts =
        TLS.server_options(
          certfile: "server.pem",
          keyfile: "server-key.pem",
          depth: 3
        )

      assert opts[:depth] == 3
    end

    test "raises when certfile is missing" do
      assert_raise ArgumentError, ~r/certfile/, fn ->
        TLS.server_options(keyfile: "server-key.pem")
      end
    end

    test "raises when keyfile is missing" do
      assert_raise ArgumentError, ~r/keyfile/, fn ->
        TLS.server_options(certfile: "server.pem")
      end
    end
  end

  describe "client_options/1" do
    test "returns options with defaults" do
      opts = TLS.client_options([])

      assert opts[:verify] == :verify_peer
      assert opts[:versions] == [:"tlsv1.2", :"tlsv1.3"]
    end

    test "allows overriding verify" do
      opts = TLS.client_options(verify: :verify_none)

      assert opts[:verify] == :verify_none
    end

    test "allows overriding versions" do
      opts = TLS.client_options(versions: [:"tlsv1.3"])

      assert opts[:versions] == [:"tlsv1.3"]
    end

    test "passes through cacertfile" do
      opts = TLS.client_options(cacertfile: "ca.pem")

      assert opts[:cacertfile] == "ca.pem"
    end
  end

  describe "mutual_tls_options/1" do
    test "returns options with defaults" do
      opts =
        TLS.mutual_tls_options(
          certfile: "server.pem",
          keyfile: "server-key.pem",
          cacertfile: "ca.pem"
        )

      assert opts[:certfile] == "server.pem"
      assert opts[:keyfile] == "server-key.pem"
      assert opts[:cacertfile] == "ca.pem"
      assert opts[:verify] == :verify_peer
      assert opts[:fail_if_no_peer_cert] == true
      assert opts[:versions] == [:"tlsv1.2", :"tlsv1.3"]
    end

    test "allows overriding verify and fail_if_no_peer_cert" do
      opts =
        TLS.mutual_tls_options(
          certfile: "server.pem",
          keyfile: "server-key.pem",
          cacertfile: "ca.pem",
          verify: :verify_none,
          fail_if_no_peer_cert: false
        )

      assert opts[:verify] == :verify_none
      assert opts[:fail_if_no_peer_cert] == false
    end

    test "raises when certfile is missing" do
      assert_raise ArgumentError, ~r/certfile/, fn ->
        TLS.mutual_tls_options(keyfile: "k.pem", cacertfile: "ca.pem")
      end
    end

    test "raises when keyfile is missing" do
      assert_raise ArgumentError, ~r/keyfile/, fn ->
        TLS.mutual_tls_options(certfile: "c.pem", cacertfile: "ca.pem")
      end
    end

    test "raises when cacertfile is missing" do
      assert_raise ArgumentError, ~r/cacertfile/, fn ->
        TLS.mutual_tls_options(certfile: "c.pem", keyfile: "k.pem")
      end
    end
  end
end
