defmodule HL7v2.MLLP.TLS do
  @moduledoc """
  TLS configuration helpers for MLLP connections.

  Provides convenience functions for building `:ssl` option lists
  suitable for server-side TLS, client-side TLS, and mutual TLS (mTLS).

  ## Server-side TLS

      tls_opts = HL7v2.MLLP.TLS.server_options(
        certfile: "server.pem",
        keyfile: "server-key.pem"
      )
      {:ok, _} = HL7v2.MLLP.Listener.start_link(port: 2576, handler: MyHandler, tls: tls_opts)

  ## Mutual TLS

      tls_opts = HL7v2.MLLP.TLS.mutual_tls_options(
        certfile: "server.pem",
        keyfile: "server-key.pem",
        cacertfile: "ca.pem"
      )

  """

  @doc """
  Builds SSL options for server-side TLS.

  ## Required options

  - `:certfile` — path to the server certificate PEM file
  - `:keyfile` — path to the server private key PEM file

  ## Optional options

  - `:cacertfile` — path to the CA certificate PEM file
  - `:versions` — TLS versions (default: `[:"tlsv1.2", :"tlsv1.3"]`)
  - Any additional `:ssl` options are passed through.

  """
  @spec server_options(keyword()) :: keyword()
  def server_options(opts) do
    opts
    |> Keyword.put_new(:versions, [:"tlsv1.2", :"tlsv1.3"])
    |> validate_required!([:certfile, :keyfile])
  end

  @doc """
  Builds SSL options for client-side TLS.

  ## Optional options

  - `:cacertfile` — path to the CA certificate PEM file
  - `:verify` — verification mode (default: `:verify_peer`)
  - `:versions` — TLS versions (default: `[:"tlsv1.2", :"tlsv1.3"]`)
  - Any additional `:ssl` options are passed through.

  """
  @spec client_options(keyword()) :: keyword()
  def client_options(opts) do
    opts
    |> Keyword.put_new(:verify, :verify_peer)
    |> Keyword.put_new(:versions, [:"tlsv1.2", :"tlsv1.3"])
  end

  @doc """
  Builds SSL options for mutual TLS (mTLS).

  Both the server and client present certificates. This is the recommended
  configuration for production MLLP endpoints.

  ## Required options

  - `:certfile` — path to the certificate PEM file
  - `:keyfile` — path to the private key PEM file
  - `:cacertfile` — path to the CA certificate PEM file

  ## Optional options

  - `:verify` — verification mode (default: `:verify_peer`)
  - `:fail_if_no_peer_cert` — reject clients without a certificate
    (default: `true`, server-side only)
  - `:versions` — TLS versions (default: `[:"tlsv1.2", :"tlsv1.3"]`)
  - Any additional `:ssl` options are passed through.

  """
  @spec mutual_tls_options(keyword()) :: keyword()
  def mutual_tls_options(opts) do
    opts
    |> Keyword.put_new(:verify, :verify_peer)
    |> Keyword.put_new(:fail_if_no_peer_cert, true)
    |> Keyword.put_new(:versions, [:"tlsv1.2", :"tlsv1.3"])
    |> validate_required!([:certfile, :keyfile, :cacertfile])
  end

  defp validate_required!(opts, keys) do
    Enum.each(keys, fn key ->
      unless Keyword.has_key?(opts, key) do
        raise ArgumentError, "TLS option #{inspect(key)} is required"
      end
    end)

    opts
  end
end
