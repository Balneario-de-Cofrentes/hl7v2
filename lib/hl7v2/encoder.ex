defmodule HL7v2.Encoder do
  @moduledoc """
  Serializes HL7v2 messages to wire format.

  Reconstructs the HL7v2 wire format from a `RawMessage` struct. The encoder
  handles the MSH-1/MSH-2 special encoding and faithfully reproduces the
  field structure present in the raw message. Round-tripping is canonical:
  the parser normalizes line endings to CR and the encoder always appends a
  trailing CR, so `parse(text) |> encode()` produces canonical wire form.

  Uses iodata internally for performance — the final result is converted to
  a binary only at the top level.

  ## Examples

      iex> {:ok, msg} = HL7v2.Parser.parse("MSH|^~\\\\&|SEND|FAC||RCV||20240101||ADT^A01|123|P|2.5\\r")
      iex> HL7v2.Encoder.encode(msg)
      "MSH|^~\\\\&|SEND|FAC||RCV||20240101||ADT^A01|123|P|2.5\\r"

  """

  alias HL7v2.{RawMessage, Separator}

  @compile {:inline, encode_field: 2, encode_components: 2, encode_sub_components: 2}

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
    [name | Enum.map(encoded_fields, &[<<sep.field>>, &1])]
  end

  # MSH encoding is special:
  # - MSH-1 (field separator) is written literally as part of "MSH|"
  # - MSH-2 (encoding characters) is written as-is, then a field separator
  # - Remaining fields are encoded normally
  defp encode_msh(fields, %Separator{} = sep) do
    case fields do
      [_msh_1, msh_2 | rest] ->
        encoded_rest = Enum.map(rest, &encode_field(&1, sep))
        ["MSH", <<sep.field>>, msh_2 | Enum.map(encoded_rest, &[<<sep.field>>, &1])]

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
      Enum.intersperse(encoded, <<sep.repetition>>)
    else
      # Single set of components (or sub-components)
      encode_components(values, sep)
    end
  end

  defp encode_components(value, _sep) when is_binary(value), do: value

  defp encode_components(components, sep) when is_list(components) do
    encoded = Enum.map(components, &encode_sub_components(&1, sep))
    Enum.intersperse(encoded, <<sep.component>>)
  end

  defp encode_sub_components(value, _sep) when is_binary(value), do: value

  defp encode_sub_components(subs, sep) when is_list(subs) do
    Enum.intersperse(subs, <<sep.sub_component>>)
  end

  # Detect whether a list represents repetitions vs components.
  #
  # The parser normalizes repetitions so every element is always a list
  # (plain-string reps are wrapped as ["value"]).  This makes the check
  # unambiguous:
  #
  #   Repetitions: [["a"], ["b", "c"]]  — all lists
  #   Components:  ["a", "b", "c"]      — flat strings
  #   Sub-comps:   ["a", ["x", "y"]]    — mixed (string + list)
  defp nested_repetitions?(values) do
    Enum.all?(values, &is_list/1)
  end
end
