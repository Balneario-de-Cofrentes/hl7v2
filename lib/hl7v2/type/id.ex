defmodule HL7v2.Type.ID do
  @moduledoc """
  Coded Value for HL7-Defined Tables (ID) -- HL7v2 primitive data type.

  String values constrained to a specific HL7-defined table.
  Pass-through storage with optional table reference metadata.
  """

  @behaviour HL7v2.Type

  @doc """
  Parses an ID string. Returns the string as-is, or `nil` for empty/nil input.

  ## Examples

      iex> HL7v2.Type.ID.parse("MR")
      "MR"

      iex> HL7v2.Type.ID.parse("")
      nil

      iex> HL7v2.Type.ID.parse(nil)
      nil

  """
  @spec parse(binary() | nil) :: binary() | nil
  def parse(nil), do: nil
  def parse(""), do: nil
  def parse(value) when is_binary(value), do: value

  @doc """
  Encodes an ID value. Returns the string as-is, or empty string for nil.

  ## Examples

      iex> HL7v2.Type.ID.encode("MR")
      "MR"

      iex> HL7v2.Type.ID.encode(nil)
      ""

  """
  @spec encode(binary() | nil) :: binary()
  def encode(nil), do: ""
  def encode(value) when is_binary(value), do: value
end
