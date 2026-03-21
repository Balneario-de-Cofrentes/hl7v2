defmodule HL7v2 do
  @moduledoc """
  Pure Elixir HL7 v2.x toolkit.

  Schema-driven parsing, typed segment structs, programmatic message
  building, validation, and integrated MLLP transport.

  ## Parsing

      # Raw mode — lossless, delimiter-based
      {:ok, raw} = HL7v2.parse(text)

      # Typed mode — validated structs
      {:ok, msg} = HL7v2.parse(text, mode: :typed)

  ## Building

      msg =
        HL7v2.Message.new("ADT", "A01", sending_application: "PHAOS")
        |> HL7v2.Message.add_segment(%HL7v2.Segment.PID{...})

      text = HL7v2.encode(msg)

  ## MLLP Transport

      {:ok, _} = HL7v2.MLLP.Listener.start_link(port: 2575, handler: MyHandler)

  """

  alias HL7v2.Parser

  @doc """
  Parses an HL7v2 message from a binary string.

  ## Options

  - `:mode` — `:raw` (default) or `:typed`
  - `:validate` — `true` to validate after parsing (default `false`)

  ## Examples

      {:ok, msg} = HL7v2.parse("MSH|^~\\\\&|...")
      {:ok, msg} = HL7v2.parse(text, mode: :typed, validate: true)

  """
  @spec parse(binary(), keyword()) :: {:ok, term()} | {:error, term()}
  def parse(text, opts \\ []) do
    Parser.parse(text, opts)
  end

  @doc """
  Encodes an HL7v2 message to wire format.
  """
  @spec encode(term()) :: binary()
  def encode(message) do
    HL7v2.Encoder.encode(message)
  end

  @doc """
  Validates an HL7v2 message.

  Returns `:ok` or `{:error, [error]}`.
  """
  @spec validate(term()) :: :ok | {:error, [map()]}
  def validate(message) do
    HL7v2.Validation.validate(message)
  end
end
