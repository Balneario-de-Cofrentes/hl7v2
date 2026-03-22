defmodule HL7v2.MLLP.Handler do
  @moduledoc """
  Behaviour for MLLP message handlers.

  Implement `handle_message/2` to process incoming HL7v2 messages and return
  a response. The handler receives the raw HL7v2 message (without MLLP framing)
  and connection metadata. The returned response message will be MLLP-framed
  before sending back to the client.

  ## Example

      defmodule MyHandler do
        @behaviour HL7v2.MLLP.Handler

        @impl true
        def handle_message(message, _meta) do
          # Parse, process, build ACK...
          {:ok, ack_message}
        end
      end

  ## Connection metadata

  The `meta` map contains:

  - `:peer` — `{address, port}` of the remote client
  - `:ref` — the Ranch listener reference
  - `:handler_state` — the value passed as `:handler_state` to the listener

  """

  @type meta :: %{
          peer: {:inet.ip_address(), :inet.port_number()},
          ref: :ranch.ref(),
          handler_state: term()
        }

  @doc """
  Handles an incoming HL7v2 message.

  Receives the raw message binary (MLLP framing already stripped) and
  connection metadata. Must return `{:ok, response_binary}` or
  `{:error, reason}`.
  """
  @callback handle_message(message :: binary(), meta :: meta()) ::
              {:ok, response :: binary()} | {:error, reason :: term()}
end
