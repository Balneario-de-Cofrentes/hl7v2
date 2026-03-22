defmodule HL7v2.Type.FT do
  @moduledoc """
  Formatted Text Data (FT) -- HL7v2 primitive data type.

  Like TX but supports embedded formatting commands enclosed in escape
  characters (e.g., `\\.sp\\` for vertical spacing). Max 65536 characters.
  Pass-through storage; formatting is interpreted by the receiving system.
  """

  @behaviour HL7v2.Type

  @doc """
  Parses formatted text. Returns the string as-is (preserving escape sequences),
  or `nil` for empty/nil input.

  ## Examples

      iex> HL7v2.Type.FT.parse("Line 1\\\\.br\\\\Line 2")
      "Line 1\\\\.br\\\\Line 2"

      iex> HL7v2.Type.FT.parse("")
      nil

      iex> HL7v2.Type.FT.parse(nil)
      nil

  """
  @spec parse(binary() | nil) :: binary() | nil
  def parse(nil), do: nil
  def parse(""), do: nil
  def parse(value) when is_binary(value), do: value

  @doc """
  Encodes formatted text. Returns the string as-is, or empty string for nil.

  ## Examples

      iex> HL7v2.Type.FT.encode("formatted content")
      "formatted content"

      iex> HL7v2.Type.FT.encode(nil)
      ""

  """
  @spec encode(binary() | nil) :: binary()
  def encode(nil), do: ""
  def encode(value) when is_binary(value), do: value
end
