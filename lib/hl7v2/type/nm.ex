defmodule HL7v2.Type.NM do
  @moduledoc """
  Numeric (NM) -- HL7v2 primitive data type.

  Format: `[+|-]digits[.digits]`. Max 16 characters.
  Parses to a `Decimal` (kept as string internally to preserve precision),
  encodes back to a canonical numeric string.
  """

  @behaviour HL7v2.Type

  # Pattern: optional sign, at least one digit before optional decimal point
  @numeric_pattern ~r/\A[+-]?\d+(\.\d+)?\z/

  @doc """
  Parses a numeric string into a normalized numeric string.

  Returns `nil` for empty/nil input. Leading/trailing whitespace is stripped.
  Leading zeros and trailing decimal zeros are normalized.

  ## Examples

      iex> HL7v2.Type.NM.parse("123")
      "123"

      iex> HL7v2.Type.NM.parse("-45.67")
      "-45.67"

      iex> HL7v2.Type.NM.parse("+01.20")
      "1.2"

      iex> HL7v2.Type.NM.parse("")
      nil

      iex> HL7v2.Type.NM.parse(nil)
      nil

  """
  @spec parse(binary() | nil) :: binary() | nil
  def parse(nil), do: nil
  def parse(""), do: nil

  def parse(value) when is_binary(value) do
    trimmed = String.trim(value)

    if Regex.match?(@numeric_pattern, trimmed) do
      normalize(trimmed)
    else
      nil
    end
  end

  @doc """
  Encodes a numeric value back to a string.

  Accepts strings and numbers. Returns empty string for nil.

  ## Examples

      iex> HL7v2.Type.NM.encode("123")
      "123"

      iex> HL7v2.Type.NM.encode(nil)
      ""

  """
  @spec encode(binary() | number() | nil) :: binary()
  def encode(nil), do: ""
  def encode(value) when is_binary(value), do: value
  def encode(value) when is_integer(value), do: Integer.to_string(value)
  def encode(value) when is_float(value), do: normalize(Float.to_string(value))

  defp normalize(str) do
    {sign, rest} =
      case str do
        "+" <> r -> {"", r}
        "-" <> r -> {"-", r}
        r -> {"", r}
      end

    normalized =
      case String.split(rest, ".", parts: 2) do
        [integer_part] ->
          strip_leading_zeros(integer_part)

        [integer_part, decimal_part] ->
          int = strip_leading_zeros(integer_part)
          dec = strip_trailing_zeros(decimal_part)

          if dec == "" do
            int
          else
            int <> "." <> dec
          end
      end

    # Drop sign for zero values
    if sign == "-" and normalized == "0" do
      "0"
    else
      sign <> normalized
    end
  end

  defp strip_leading_zeros(""), do: "0"
  defp strip_leading_zeros("0"), do: "0"

  defp strip_leading_zeros(str) do
    stripped = String.replace_leading(str, "0", "")
    if stripped == "", do: "0", else: stripped
  end

  defp strip_trailing_zeros(str) do
    String.replace_trailing(str, "0", "")
  end
end
