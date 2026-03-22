defmodule HL7v2.Type.NM do
  @moduledoc """
  Numeric (NM) -- HL7v2 primitive data type.

  Format: `[+|-]digits[.digits]`. Max 16 characters.

  Parses to a `%NM{}` struct that holds both a normalized `value` (for
  computation) and the `original` wire string (for lossless round-trip).
  `encode/1` emits `original` when present so that parse-then-encode
  preserves the exact wire format.  Programmatically-built structs
  (where `original` is nil) fall back to emitting `value`.
  """

  @behaviour HL7v2.Type

  defstruct [:value, :original]

  @type t :: %__MODULE__{
          value: binary(),
          original: binary() | nil
        }

  # Pattern: optional sign, at least one digit before optional decimal point
  @numeric_pattern ~r/\A[+-]?\d+(\.\d+)?\z/

  @doc """
  Parses a numeric string into a `%NM{}` struct.

  Returns `nil` for empty/nil input. Leading/trailing whitespace is stripped.
  The `value` field holds the normalized form (leading zeros, trailing decimal
  zeros and bare `+` stripped). The `original` field preserves the raw input
  for lossless round-trip encoding.

  ## Examples

      iex> HL7v2.Type.NM.parse("123")
      %HL7v2.Type.NM{value: "123", original: "123"}

      iex> HL7v2.Type.NM.parse("-45.67")
      %HL7v2.Type.NM{value: "-45.67", original: "-45.67"}

      iex> HL7v2.Type.NM.parse("+01.20")
      %HL7v2.Type.NM{value: "1.2", original: "+01.20"}

      iex> HL7v2.Type.NM.parse("")
      nil

      iex> HL7v2.Type.NM.parse(nil)
      nil

  """
  @spec parse(binary() | nil) :: t() | nil
  def parse(nil), do: nil
  def parse(""), do: nil

  def parse(value) when is_binary(value) do
    trimmed = String.trim(value)

    if Regex.match?(@numeric_pattern, trimmed) do
      # Preserve the raw wire value (with any whitespace) for lossless round-trip.
      # Normalize only the trimmed form for programmatic access.
      %__MODULE__{value: normalize(trimmed), original: value}
    else
      nil
    end
  end

  @doc """
  Encodes a numeric value back to a string.

  For `%NM{}` structs, emits `original` when present (preserving the wire
  format), falling back to `value` when `original` is nil (programmatically
  built values).

  Also accepts plain strings and numbers for backward compatibility.

  ## Examples

      iex> HL7v2.Type.NM.encode(%HL7v2.Type.NM{value: "1.2", original: "+01.20"})
      "+01.20"

      iex> HL7v2.Type.NM.encode(%HL7v2.Type.NM{value: "42"})
      "42"

      iex> HL7v2.Type.NM.encode("123")
      "123"

      iex> HL7v2.Type.NM.encode(nil)
      ""

  """
  @spec encode(t() | binary() | number() | nil) :: binary()
  def encode(nil), do: ""
  def encode(%__MODULE__{original: original, value: value}), do: original || value
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
