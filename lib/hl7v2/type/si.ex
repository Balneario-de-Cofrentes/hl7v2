defmodule HL7v2.Type.SI do
  @moduledoc """
  Sequence ID (SI) -- HL7v2 primitive data type.

  Non-negative integer, range 0-9999. Used as sequential counter
  within repeating structures (e.g., Set ID fields).
  """

  @behaviour HL7v2.Type

  @doc """
  Parses a sequence ID string into an integer.

  Returns `nil` for empty/nil input. Only valid non-negative integers
  are accepted (range 0-9999).

  ## Examples

      iex> HL7v2.Type.SI.parse("1")
      1

      iex> HL7v2.Type.SI.parse("0")
      0

      iex> HL7v2.Type.SI.parse("9999")
      9999

      iex> HL7v2.Type.SI.parse("")
      nil

      iex> HL7v2.Type.SI.parse(nil)
      nil

  """
  @spec parse(binary() | nil) :: non_neg_integer() | nil
  def parse(nil), do: nil
  def parse(""), do: nil

  def parse(value) when is_binary(value) do
    case Integer.parse(String.trim(value)) do
      {n, ""} when n >= 0 and n <= 9999 -> n
      # Preserve invalid value as raw string for lossless round-trip
      _ -> value
    end
  end

  @doc """
  Encodes a sequence ID integer to a string.

  ## Examples

      iex> HL7v2.Type.SI.encode(1)
      "1"

      iex> HL7v2.Type.SI.encode(nil)
      ""

  """
  @spec encode(non_neg_integer() | binary() | nil) :: binary()
  def encode(nil), do: ""
  def encode(value) when is_integer(value) and value >= 0, do: Integer.to_string(value)
  def encode(value) when is_binary(value), do: value
end
