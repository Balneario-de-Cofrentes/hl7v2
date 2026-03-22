defmodule HL7v2.Parser do
  @moduledoc """
  Parses HL7v2 messages into raw (lossless) representation.

  The parser splits the message into segments, fields, repetitions, components,
  and sub-components using the delimiters declared in the MSH segment header.
  No type coercion or validation is performed — the output preserves the original
  wire format exactly.

  ## MSH-1/MSH-2 Special Handling

  MSH-1 (field separator) and MSH-2 (encoding characters) are not regular
  delimited fields. The parser handles them as special cases:

  - MSH-1 is stored as a single-byte binary (the field separator character)
  - MSH-2 is stored as a 4-character literal string (encoding characters)
  - Remaining MSH fields start at field index 2 (MSH-3 = index 2)

  ## Examples

      iex> {:ok, msg} = HL7v2.Parser.parse("MSH|^~\\\\&|SEND|FAC||RCV||20240101||ADT^A01|123|P|2.5\\r")
      iex> msg.type
      {"ADT", "A01"}
      iex> length(msg.segments)
      1

  """

  alias HL7v2.{RawMessage, Separator, TypedParser}

  @doc """
  Parses an HL7v2 message binary into a `RawMessage` struct.

  ## Options

  - `:mode` — `:raw` (default) or `:typed` for parsed segment structs.

  Returns `{:ok, raw_message}` or `{:error, reason}`.
  """
  @spec parse(binary(), keyword()) ::
          {:ok, RawMessage.t() | HL7v2.TypedMessage.t()} | {:error, term()}
  def parse(text, opts \\ [])

  def parse("", _opts), do: {:error, :empty_message}

  def parse(text, opts) do
    mode = Keyword.get(opts, :mode, :raw)

    case mode do
      :raw ->
        parse_raw(text)

      :typed ->
        with {:ok, raw} <- parse_raw(text) do
          TypedParser.convert(raw)
        end

      other ->
        {:error, {:unknown_mode, other}}
    end
  end

  defp parse_raw(text) do
    text = normalize_line_endings(text)

    with {:ok, separators} <- Separator.from_msh(text),
         {:ok, segment_texts} <- split_segments(text, separators),
         {:ok, segments} <- parse_segments(segment_texts, separators),
         {:ok, msg_type} <- extract_message_type(segments, separators) do
      {:ok,
       %RawMessage{
         separators: separators,
         type: msg_type,
         segments: segments
       }}
    end
  end

  # Normalize CRLF and LF to CR (the HL7v2 segment terminator)
  defp normalize_line_endings(text) do
    text
    |> String.replace("\r\n", "\r")
    |> String.replace("\n", "\r")
  end

  defp split_segments(text, %Separator{segment: seg}) do
    segments =
      text
      |> String.split(<<seg>>, trim: true)
      |> Enum.reject(&(&1 == ""))

    if segments == [] do
      {:error, :empty_message}
    else
      {:ok, segments}
    end
  end

  defp parse_segments(segment_texts, separators) do
    segments = Enum.map(segment_texts, &parse_segment(&1, separators))
    {:ok, segments}
  end

  defp parse_segment(segment_text, %Separator{} = sep) do
    field_sep = <<sep.field>>

    case segment_text do
      <<"MSH", _rest::binary>> ->
        parse_msh_segment(segment_text, sep)

      _ ->
        [name | fields] = String.split(segment_text, field_sep)
        parsed_fields = Enum.map(fields, &parse_field(&1, sep))
        {name, parsed_fields}
    end
  end

  # MSH is special: MSH-1 is the field separator itself (not delimited),
  # MSH-2 is the 4 encoding characters (literal, not delimited).
  defp parse_msh_segment(<<"MSH", field_sep, rest::binary>>, %Separator{} = sep) do
    # MSH-1 = the field separator character
    msh_1 = <<field_sep>>

    # MSH-2 = encoding characters (next 4 bytes, up to the next field separator)
    {msh_2, remaining} = extract_msh_2(rest, sep)

    # Remaining fields are regular delimited fields (MSH-3 onwards)
    remaining_fields =
      case remaining do
        "" -> []
        _ -> remaining |> String.split(<<sep.field>>) |> Enum.map(&parse_field(&1, sep))
      end

    {"MSH", [msh_1, msh_2 | remaining_fields]}
  end

  defp extract_msh_2(rest, %Separator{} = sep) do
    # MSH-2 is everything up to the next field separator
    field_sep = <<sep.field>>

    case String.split(rest, field_sep, parts: 2) do
      [msh_2, remaining] -> {msh_2, remaining}
      [msh_2] -> {msh_2, ""}
    end
  end

  defp parse_field("", _sep), do: ""

  defp parse_field(field_text, %Separator{} = sep) do
    rep_sep = <<sep.repetition>>

    repetitions = String.split(field_text, rep_sep)

    case repetitions do
      [single] ->
        # No repetitions — parse components
        parse_components(single, sep)

      multiple ->
        # Has repetitions — each repetition gets component parsing
        Enum.map(multiple, &parse_components(&1, sep))
    end
  end

  defp parse_components(text, %Separator{} = sep) do
    comp_sep = <<sep.component>>
    components = String.split(text, comp_sep)

    case components do
      [single] ->
        # No components — parse sub-components
        parse_sub_components(single, sep)

      multiple ->
        # Has components — each may have sub-components
        Enum.map(multiple, &parse_sub_components(&1, sep))
    end
  end

  defp parse_sub_components(text, %Separator{} = sep) do
    sub_sep = <<sep.sub_component>>
    subs = String.split(text, sub_sep)

    case subs do
      [single] -> single
      multiple -> multiple
    end
  end

  # Extract message type from MSH-9 (field index 8 in our 0-indexed field list,
  # remembering MSH-1 is index 0, MSH-2 is index 1, MSH-3 is index 2, ...)
  # MSH-9 = index 8
  defp extract_message_type(segments, %Separator{} = _sep) do
    case segments do
      [{"MSH", fields} | _] when length(fields) > 8 ->
        msh_9 = Enum.at(fields, 8)
        {:ok, parse_message_type(msh_9)}

      [{"MSH", _} | _] ->
        {:error, :missing_message_type}

      _ ->
        {:error, :first_segment_not_msh}
    end
  end

  defp parse_message_type(components) when is_list(components) do
    case components do
      [code, event, structure | _] -> {code, event, structure}
      [code, event] -> {code, event}
      [code] -> {code, ""}
      [] -> {"", ""}
    end
  end

  defp parse_message_type(value) when is_binary(value) do
    {value, ""}
  end
end
