defmodule HL7v2.Type.IS do
  @moduledoc """
  Coded Value for User-Defined Tables (IS) -- HL7v2 primitive data type.

  String values constrained to a site-defined (user-defined) table.
  Pass-through storage. Max 20 characters by default.
  """

  @behaviour HL7v2.Type

  @doc """
  Parses an IS string. Returns the string as-is, or `nil` for empty/nil input.

  ## Examples

      iex> HL7v2.Type.IS.parse("ICU")
      "ICU"

      iex> HL7v2.Type.IS.parse("")
      nil

      iex> HL7v2.Type.IS.parse(nil)
      nil

  """
  @spec parse(binary() | nil) :: binary() | nil
  def parse(nil), do: nil
  def parse(""), do: nil
  def parse(value) when is_binary(value), do: value

  @doc """
  Encodes an IS value. Returns the string as-is, or empty string for nil.

  ## Examples

      iex> HL7v2.Type.IS.encode("ICU")
      "ICU"

      iex> HL7v2.Type.IS.encode(nil)
      ""

  """
  @spec encode(binary() | nil) :: binary()
  def encode(nil), do: ""
  def encode(value) when is_binary(value), do: value
end
