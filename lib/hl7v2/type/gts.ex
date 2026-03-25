defmodule HL7v2.Type.GTS do
  @moduledoc """
  General Timing Specification (GTS) -- HL7v2 primitive data type.

  An expression representing a general timing specification, following the
  HL7 timing syntax. Treated as an opaque string -- the library does not
  parse the timing expression itself.
  """

  @behaviour HL7v2.Type

  @type t :: binary() | nil

  @doc """
  Parses a GTS value. Returns the raw string.

  ## Examples

      iex> HL7v2.Type.GTS.parse("200602011430-0500")
      "200602011430-0500"

      iex> HL7v2.Type.GTS.parse("")
      nil

      iex> HL7v2.Type.GTS.parse(nil)
      nil

  """
  @spec parse(binary() | nil) :: t()
  def parse(nil), do: nil
  def parse(""), do: nil
  def parse(value) when is_binary(value), do: value

  @doc """
  Encodes a GTS value back to a string.

  ## Examples

      iex> HL7v2.Type.GTS.encode("200602011430-0500")
      "200602011430-0500"

      iex> HL7v2.Type.GTS.encode(nil)
      ""

  """
  @spec encode(t()) :: binary()
  def encode(nil), do: ""
  def encode(value) when is_binary(value), do: value
end
