defmodule HL7v2.Encoder do
  @moduledoc """
  Serializes HL7v2 messages to wire format.

  Reconstructs the HL7v2 wire format from a `RawMessage` struct. The encoder
  handles the MSH-1/MSH-2 special encoding and trims trailing empty fields
  and components.

  Uses iodata internally for performance — the final result is converted to
  a binary only at the top level.

  ## Examples

      iex> {:ok, msg} = HL7v2.Parser.parse("MSH|^~\\\\&|SEND|FAC||RCV||20240101||ADT^A01|123|P|2.5\\r")
      iex> HL7v2.Encoder.encode(msg)
      "MSH|^~\\\\&|SEND|FAC||RCV||20240101||ADT^A01|123|P|2.5\\r"

  """

  alias HL7v2.{RawMessage, Separator}

  @doc """
  Encodes a `RawMessage` to its HL7v2 wire format binary.

  Each segment is terminated by the segment separator (CR by default).
  MSH-1 and MSH-2 receive special treatment to match the standard encoding.
  """
  @spec encode(RawMessage.t()) :: binary()
  def encode(%RawMessage{separators: sep, segments: segments}) do
    segments
    |> Enum.map(&encode_segment(&1, sep))
    |> Enum.intersperse(<<sep.segment>>)
    |> then(&[&1, <<sep.segment>>])
    |> IO.iodata_to_binary()
  end

  defp encode_segment({"MSH", fields}, %Separator{} = sep) do
    encode_msh(fields, sep)
  end

  defp encode_segment({name, fields}, %Separator{} = sep) do
    encoded_fields = Enum.map(fields, &encode_field(&1, sep))
    trimmed = trim_trailing_empty(encoded_fields)
    [name | Enum.map(trimmed, &[<<sep.field>>, &1])]
  end

  # MSH encoding is special:
  # - MSH-1 (field separator) is written literally as part of "MSH|"
  # - MSH-2 (encoding characters) is written as-is, then a field separator
  # - Remaining fields are encoded normally
  defp encode_msh(fields, %Separator{} = sep) do
    case fields do
      [_msh_1, msh_2 | rest] ->
        encoded_rest = Enum.map(rest, &encode_field(&1, sep))
        trimmed = trim_trailing_empty(encoded_rest)
        ["MSH", <<sep.field>>, msh_2 | Enum.map(trimmed, &[<<sep.field>>, &1])]

      [_msh_1] ->
        ["MSH", <<sep.field>>]

      [] ->
        ["MSH", <<sep.field>>]
    end
  end

  defp encode_field("", _sep), do: ""
  defp encode_field(value, _sep) when is_binary(value), do: value

  defp encode_field(values, sep) when is_list(values) do
    if nested_repetitions?(values) do
      # List of repetitions — each element is a component list or string
      encoded = Enum.map(values, &encode_components(&1, sep))
      trimmed = trim_trailing_empty(encoded)
      Enum.intersperse(trimmed, <<sep.repetition>>)
    else
      # Single set of components (or sub-components)
      encode_components(values, sep)
    end
  end

  defp encode_components(value, _sep) when is_binary(value), do: value

  defp encode_components(components, sep) when is_list(components) do
    encoded = Enum.map(components, &encode_sub_components(&1, sep))
    trimmed = trim_trailing_empty(encoded)
    Enum.intersperse(trimmed, <<sep.component>>)
  end

  defp encode_sub_components(value, _sep) when is_binary(value), do: value

  defp encode_sub_components(subs, sep) when is_list(subs) do
    trimmed = trim_trailing_empty(subs)
    Enum.intersperse(trimmed, <<sep.sub_component>>)
  end

  # Detect whether a list represents repetitions (list of component-lists)
  # vs a single set of components (list of strings/sub-component-lists).
  #
  # Repetitions: [[c1, c2], [c3, c4]] — outer list of inner lists
  # Components: [c1, c2, c3] — flat list of strings
  # Sub-components within components: ["a", ["x", "y"]] — mixed
  #
  # A field has repetitions when it's a list where at least one element is itself a list.
  # But we also need to distinguish from sub-components.
  # The key insight: repetitions contain component-level lists, while components
  # contain sub-component lists. The ambiguity only arises at the field level.
  #
  # Heuristic: if every element is either a list or a binary, and at least one
  # is a list, check if those inner lists could be component sets.
  # Actually, the parser produces unambiguous structures:
  # - No repetitions, no components: "value"
  # - Components only: ["a", "b", "c"]
  # - Repetitions (each with components): [["a", "b"], ["c", "d"]]
  # - Sub-components: ["a", ["x", "y"]] — component list with one sub-component element
  #
  # So: if every element is a list, it's repetitions.
  # If elements are mixed (some lists, some strings), it's components with sub-components.
  defp nested_repetitions?(values) do
    Enum.all?(values, &is_list/1)
  end

  # Trim trailing empty strings/iodata from a list, preserving leading/middle empties.
  defp trim_trailing_empty(list) do
    list
    |> Enum.reverse()
    |> Enum.drop_while(&iodata_empty?/1)
    |> Enum.reverse()
  end

  defp iodata_empty?(""), do: true
  defp iodata_empty?([]), do: true
  defp iodata_empty?(_), do: false
end
