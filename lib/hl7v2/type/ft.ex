defmodule HL7v2.Type.FT do
  @moduledoc """
  Formatted Text Data (FT) -- HL7v2 primitive data type.

  Lossless storage: the value is stored and returned as a plain binary string.
  The HL7 spec says FT supports embedded formatting commands (e.g., `\\.sp\\`
  for vertical spacing), but this implementation preserves all input bytes
  for round-trip fidelity. No formatting interpretation, escape processing,
  or length enforcement is performed.
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
