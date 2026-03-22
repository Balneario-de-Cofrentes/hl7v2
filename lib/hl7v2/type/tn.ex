defmodule HL7v2.Type.TN do
  @moduledoc """
  Telephone Number (TN) -- HL7v2 primitive data type.

  Deprecated as of v2.3. Retained for backward compatibility with
  pre-v2.3 messages. Max 199 characters. Pass-through string storage.
  Use XTN for new implementations.
  """

  @behaviour HL7v2.Type

  @doc """
  Parses a telephone number string. Pass-through.

  ## Examples

      iex> HL7v2.Type.TN.parse("(555)555-1234X5678")
      "(555)555-1234X5678"

      iex> HL7v2.Type.TN.parse("")
      nil

      iex> HL7v2.Type.TN.parse(nil)
      nil

  """
  @spec parse(binary() | nil) :: binary() | nil
  def parse(nil), do: nil
  def parse(""), do: nil
  def parse(value) when is_binary(value), do: value

  @doc """
  Encodes a telephone number. Pass-through.

  ## Examples

      iex> HL7v2.Type.TN.encode("(555)555-1234")
      "(555)555-1234"

      iex> HL7v2.Type.TN.encode(nil)
      ""

  """
  @spec encode(binary() | nil) :: binary()
  def encode(nil), do: ""
  def encode(value) when is_binary(value), do: value
end
