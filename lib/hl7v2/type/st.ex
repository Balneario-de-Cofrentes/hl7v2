defmodule HL7v2.Type.ST do
  @moduledoc """
  String Data (ST) -- HL7v2 primitive data type.

  Printable characters, left-justified, max 199 characters by default.
  Pass-through: the value is stored and returned as a plain binary string.
  """

  @behaviour HL7v2.Type

  @doc """
  Parses a string value. Returns the string as-is, or `nil` for empty/nil input.

  ## Examples

      iex> HL7v2.Type.ST.parse("Hello")
      "Hello"

      iex> HL7v2.Type.ST.parse("")
      nil

      iex> HL7v2.Type.ST.parse(nil)
      nil

  """
  @spec parse(binary() | nil) :: binary() | nil
  def parse(nil), do: nil
  def parse(""), do: nil
  def parse(value) when is_binary(value), do: value

  @doc """
  Encodes a string value. Returns the string as-is, or empty string for nil.

  ## Examples

      iex> HL7v2.Type.ST.encode("Hello")
      "Hello"

      iex> HL7v2.Type.ST.encode(nil)
      ""

  """
  @spec encode(binary() | nil) :: binary()
  def encode(nil), do: ""
  def encode(value) when is_binary(value), do: value
end
