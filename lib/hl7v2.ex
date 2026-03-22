defmodule HL7v2 do
  @moduledoc """
  Pure Elixir HL7 v2.x toolkit.

  Schema-driven parsing, typed segment structs, programmatic message
  building, validation, and integrated MLLP transport.

  ## Parsing

      # Raw mode — canonical round-trip, delimiter-based
      {:ok, raw} = HL7v2.parse(text)

      # Typed mode — segments become structs
      {:ok, msg} = HL7v2.parse(text, mode: :typed)

  ## Building

      msg =
        HL7v2.new("ADT", "A01", sending_application: "PHAOS")
        |> HL7v2.Message.add_segment(%HL7v2.Segment.PID{...})

      text = HL7v2.encode(msg)

  ## Acknowledgments

      {:ok, typed} = HL7v2.parse(wire, mode: :typed)
      msh = hd(typed.segments)
      {ack_msh, msa} = HL7v2.ack(msh)

  ## MLLP Transport

      {:ok, _} = HL7v2.MLLP.Listener.start_link(port: 2575, handler: MyHandler)

  """

  alias HL7v2.{Parser, Telemetry}

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
    mode = Keyword.get(opts, :mode, :raw)
    validate? = Keyword.get(opts, :validate, false)

    Telemetry.span(:parse, %{mode: mode}, fn ->
      with {:ok, msg} <- Parser.parse(text, opts) do
        if validate? and mode == :typed do
          case HL7v2.Validation.validate(msg) do
            :ok -> {:ok, msg}
            {:error, _} = err -> err
          end
        else
          {:ok, msg}
        end
      end
    end)
  end

  @doc """
  Encodes an HL7v2 message to wire format.

  Accepts:

  - `%HL7v2.RawMessage{}` — encodes directly
  - `%HL7v2.Message{}` — converts to raw via `Message.encode/1`
  - `%HL7v2.TypedMessage{}` — converts to raw via `TypedParser.to_raw/1`, then encodes

  ## Examples

      wire = HL7v2.encode(raw_message)
      wire = HL7v2.encode(builder_message)
      wire = HL7v2.encode(typed_message)

  """
  @spec encode(HL7v2.RawMessage.t() | HL7v2.Message.t() | HL7v2.TypedMessage.t()) :: binary()
  def encode(%HL7v2.RawMessage{} = message) do
    Telemetry.span(:encode, %{type: :raw}, fn ->
      HL7v2.Encoder.encode(message)
    end)
  end

  def encode(%HL7v2.Message{} = message) do
    Telemetry.span(:encode, %{type: :message}, fn ->
      HL7v2.Message.encode(message)
    end)
  end

  def encode(%HL7v2.TypedMessage{} = message) do
    Telemetry.span(:encode, %{type: :typed}, fn ->
      message
      |> HL7v2.TypedParser.to_raw()
      |> HL7v2.Encoder.encode()
    end)
  end

  @doc """
  Validates an HL7v2 typed message.

  Returns `:ok` when all validation rules pass, or `{:error, errors}` with
  a list of error/warning maps. Requires a `HL7v2.TypedMessage` -- raw messages
  return `{:error, :not_a_typed_message}`.

  ## Examples

      {:ok, msg} = HL7v2.parse(text, mode: :typed)
      :ok = HL7v2.validate(msg)

  """
  @spec validate(term()) :: :ok | {:error, [map()] | :not_a_typed_message}
  def validate(%HL7v2.TypedMessage{} = message) do
    HL7v2.Validation.validate(message)
  end

  def validate(_message) do
    {:error, :not_a_typed_message}
  end

  @doc """
  Builds a new HL7v2 message. Shortcut for `HL7v2.Message.new/3`.

  ## Options

    * `:sending_application` — string or `%HD{}`
    * `:sending_facility` — string or `%HD{}`
    * `:receiving_application` — string or `%HD{}`
    * `:receiving_facility` — string or `%HD{}`
    * `:message_control_id` — string (default: auto-generated)
    * `:processing_id` — string (default: `"P"`)
    * `:version_id` — string (default: `"2.5.1"`)

  ## Examples

      msg = HL7v2.new("ADT", "A01", sending_application: "PHAOS")

  """
  @spec new(binary(), binary(), keyword()) :: HL7v2.Message.t()
  def new(code, event, opts \\ []) do
    HL7v2.Message.new(code, event, opts)
  end

  @doc "Gets a value from a typed message using a path string like `\"PID-5\"` or `\"MSH-9.1\"`."
  @spec get(HL7v2.TypedMessage.t(), binary()) :: term()
  defdelegate get(msg, path), to: HL7v2.Access

  @doc "Gets a value from a typed message with a default."
  @spec get(HL7v2.TypedMessage.t(), binary(), term()) :: term()
  defdelegate get(msg, path, default), to: HL7v2.Access

  @doc """
  Builds an ACK (Application Accept) for the given MSH segment.

  Shortcut for `HL7v2.Ack.accept/2`.

  ## Options

    * `:text` — optional text message for MSA-3
    * `:message_control_id` — override the generated ACK message control ID

  ## Examples

      {ack_msh, msa} = HL7v2.ack(original_msh)

  """
  @spec ack(HL7v2.Segment.MSH.t(), keyword()) :: {HL7v2.Segment.MSH.t(), HL7v2.Segment.MSA.t()}
  def ack(msh, opts \\ []) do
    HL7v2.Ack.accept(msh, opts)
  end
end
