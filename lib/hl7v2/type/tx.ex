defmodule HL7v2.Type.TX do
  @moduledoc """
  Text Data (TX) -- HL7v2 primitive data type.

  Display-oriented narrative text. Leading spaces ARE significant and must be
  preserved (unlike ST). Trailing spaces are removed. Supports escape
  sequences for display control. No intrinsic length limit.
  """

  @behaviour HL7v2.Type

  @doc """
  Parses a text value. Returns the string as-is (preserving leading whitespace),
  or `nil` for empty/nil input.

  ## Examples

      iex> HL7v2.Type.TX.parse("  indented text")
      "  indented text"

      iex> HL7v2.Type.TX.parse("simple text")
      "simple text"

      iex> HL7v2.Type.TX.parse("")
      nil

      iex> HL7v2.Type.TX.parse(nil)
      nil

  """
  @spec parse(binary() | nil) :: binary() | nil
  def parse(nil), do: nil
  def parse(""), do: nil
  def parse(value) when is_binary(value), do: value

  @doc """
  Encodes a text value. Returns the string as-is, or empty string for nil.

  ## Examples

      iex> HL7v2.Type.TX.encode("  indented text")
      "  indented text"

      iex> HL7v2.Type.TX.encode(nil)
      ""

  """
  @spec encode(binary() | nil) :: binary()
  def encode(nil), do: ""
  def encode(value) when is_binary(value), do: value
end
