defmodule HL7v2.Escape do
  @moduledoc """
  Encodes and decodes HL7v2 escape sequences.

  Delimiter characters appearing in field data must be escaped so they are not
  confused with structural separators. The standard escape sequences are:

  | Sequence   | Meaning                           |
  |------------|-----------------------------------|
  | `\\F\\`    | Field separator (default `|`)     |
  | `\\S\\`    | Component separator (default `^`) |
  | `\\T\\`    | Sub-component separator (`&`)     |
  | `\\R\\`    | Repetition separator (`~`)        |
  | `\\E\\`    | Escape character (`\\`)           |
  | `\\Xdd\\`  | Hexadecimal data                  |
  | `\\.br\\`  | Line break                        |

  Unrecognized escape sequences are passed through unchanged.
  """

  alias HL7v2.Separator

  @doc """
  Decodes HL7v2 escape sequences in `text`, replacing them with literal characters.

  ## Examples

      iex> sep = HL7v2.Separator.default()
      iex> HL7v2.Escape.decode("foo\\\\F\\\\bar", sep)
      "foo|bar"

      iex> sep = HL7v2.Separator.default()
      iex> HL7v2.Escape.decode("line1\\\\.br\\\\line2", sep)
      "line1\\r\\nline2"

  """
  @spec decode(binary(), Separator.t()) :: binary()
  def decode(text, %Separator{} = sep) do
    esc = sep.escape
    do_decode(text, esc, sep, [])
  end

  defp do_decode(<<>>, _esc, _sep, acc), do: acc |> Enum.reverse() |> IO.iodata_to_binary()

  defp do_decode(<<esc, rest::binary>>, esc, sep, acc) do
    case extract_sequence(rest, esc) do
      {:ok, seq, remainder} ->
        decoded = decode_sequence(seq, sep)
        do_decode(remainder, esc, sep, [decoded | acc])

      :no_closing ->
        # No closing escape char — treat the escape literally
        do_decode(rest, esc, sep, [<<esc>> | acc])
    end
  end

  defp do_decode(<<byte, rest::binary>>, esc, sep, acc) do
    do_decode(rest, esc, sep, [<<byte>> | acc])
  end

  defp extract_sequence(data, esc) do
    case :binary.match(data, <<esc>>) do
      {pos, 1} ->
        seq = binary_part(data, 0, pos)
        remainder = binary_part(data, pos + 1, byte_size(data) - pos - 1)
        {:ok, seq, remainder}

      :nomatch ->
        :no_closing
    end
  end

  defp decode_sequence("F", sep), do: <<sep.field>>
  defp decode_sequence("S", sep), do: <<sep.component>>
  defp decode_sequence("T", sep), do: <<sep.sub_component>>
  defp decode_sequence("R", sep), do: <<sep.repetition>>
  defp decode_sequence("E", sep), do: <<sep.escape>>
  defp decode_sequence(".br", _sep), do: "\r\n"

  defp decode_sequence(<<".sp", rest::binary>>, _sep) do
    n = parse_space_count(rest)
    String.duplicate(" ", n)
  end

  defp decode_sequence(<<"X", hex::binary>>, _sep) do
    decode_hex(hex)
  end

  # Unrecognized sequences: pass through with escape delimiters
  defp decode_sequence(seq, sep) do
    <<sep.escape>> <> seq <> <<sep.escape>>
  end

  defp parse_space_count(""), do: 1
  defp parse_space_count(" " <> rest), do: parse_space_count(rest)

  defp parse_space_count(s) do
    case Integer.parse(String.trim(s)) do
      {n, _} when n > 0 -> n
      _ -> 1
    end
  end

  defp decode_hex(hex) do
    hex
    |> String.upcase()
    |> do_decode_hex([])
  end

  defp do_decode_hex(<<>>, acc), do: acc |> Enum.reverse() |> IO.iodata_to_binary()

  defp do_decode_hex(<<hi, lo, rest::binary>>, acc) do
    byte = hex_to_int(hi) * 16 + hex_to_int(lo)
    do_decode_hex(rest, [<<byte>> | acc])
  end

  # Odd-length hex — ignore trailing nibble
  defp do_decode_hex(<<_>>, acc), do: acc |> Enum.reverse() |> IO.iodata_to_binary()

  defp hex_to_int(c) when c in ?0..?9, do: c - ?0
  defp hex_to_int(c) when c in ?A..?F, do: c - ?A + 10
  defp hex_to_int(c) when c in ?a..?f, do: c - ?a + 10

  @doc """
  Encodes delimiter characters in `text` as HL7v2 escape sequences.

  This is the inverse of `decode/2`. Characters matching any of the separator's
  delimiters are replaced with their escape sequence equivalents.

  ## Examples

      iex> sep = HL7v2.Separator.default()
      iex> HL7v2.Escape.encode("pipe|here", sep)
      "pipe\\\\F\\\\here"

      iex> sep = HL7v2.Separator.default()
      iex> HL7v2.Escape.encode("no specials", sep)
      "no specials"

  """
  @spec encode(binary(), Separator.t()) :: binary()
  def encode(text, %Separator{} = sep) do
    do_encode(text, sep, [])
  end

  defp do_encode(<<>>, _sep, acc), do: acc |> Enum.reverse() |> IO.iodata_to_binary()

  defp do_encode(<<byte, rest::binary>>, sep, acc) do
    replacement =
      cond do
        byte == sep.escape -> [<<sep.escape>>, "E", <<sep.escape>>]
        byte == sep.field -> [<<sep.escape>>, "F", <<sep.escape>>]
        byte == sep.component -> [<<sep.escape>>, "S", <<sep.escape>>]
        byte == sep.sub_component -> [<<sep.escape>>, "T", <<sep.escape>>]
        byte == sep.repetition -> [<<sep.escape>>, "R", <<sep.escape>>]
        true -> <<byte>>
      end

    do_encode(rest, sep, [replacement | acc])
  end
end
