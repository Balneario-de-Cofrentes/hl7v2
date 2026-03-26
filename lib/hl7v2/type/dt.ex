defmodule HL7v2.Type.DT do
  @moduledoc """
  Date (DT) -- HL7v2 primitive data type.

  Format: `YYYY[MM[DD]]`. Supports year, month, and day precision.
  Parses to an `%HL7v2.Type.DT{}` struct preserving precision, or a `Date`
  when full day precision is available.
  """

  @behaviour HL7v2.Type

  defstruct [:year, :month, :day, :original]

  @type t :: %__MODULE__{
          year: pos_integer(),
          month: pos_integer() | nil,
          day: pos_integer() | nil
        }

  @doc """
  Parses a date string in `YYYY[MM[DD]]` format.

  Returns a `Date` struct when fully specified (8 digits), or an
  `%HL7v2.Type.DT{}` struct for partial dates.

  ## Examples

      iex> HL7v2.Type.DT.parse("19880704")
      ~D[1988-07-04]

      iex> HL7v2.Type.DT.parse("199503")
      %HL7v2.Type.DT{year: 1995, month: 3, day: nil}

      iex> HL7v2.Type.DT.parse("2026")
      %HL7v2.Type.DT{year: 2026, month: nil, day: nil}

      iex> HL7v2.Type.DT.parse("")
      nil

      iex> HL7v2.Type.DT.parse(nil)
      nil

  """
  @spec parse(binary() | nil) :: Date.t() | t() | nil
  def parse(nil), do: nil
  def parse(""), do: nil

  def parse(<<y::binary-size(4), m::binary-size(2), d::binary-size(2)>> = raw) do
    with {year, ""} <- Integer.parse(y),
         {month, ""} <- Integer.parse(m),
         {day, ""} <- Integer.parse(d),
         {:ok, date} <- Date.new(year, month, day) do
      date
    else
      # Invalid date — preserve raw string for lossless round-trip
      _ -> %__MODULE__{original: raw}
    end
  end

  def parse(<<y::binary-size(4), m::binary-size(2)>> = raw) do
    with {year, ""} <- Integer.parse(y),
         {month, ""} <- Integer.parse(m),
         true <- month in 1..12 do
      %__MODULE__{year: year, month: month}
    else
      _ -> %__MODULE__{original: raw}
    end
  end

  def parse(<<y::binary-size(4)>> = raw) do
    case Integer.parse(y) do
      {year, ""} when year > 0 -> %__MODULE__{year: year}
      _ -> %__MODULE__{original: raw}
    end
  end

  def parse(value) when is_binary(value), do: %__MODULE__{original: value}
  def parse(_), do: nil

  @doc """
  Encodes a date value to `YYYYMMDD`, `YYYYMM`, or `YYYY` format.

  ## Examples

      iex> HL7v2.Type.DT.encode(~D[1988-07-04])
      "19880704"

      iex> HL7v2.Type.DT.encode(%HL7v2.Type.DT{year: 1995, month: 3})
      "199503"

      iex> HL7v2.Type.DT.encode(%HL7v2.Type.DT{year: 2026})
      "2026"

      iex> HL7v2.Type.DT.encode(nil)
      ""

  """
  @spec encode(Date.t() | t() | nil) :: binary()
  def encode(nil), do: ""

  # Preserved invalid value — emit raw string for lossless round-trip
  def encode(%__MODULE__{original: original}) when is_binary(original), do: original

  def encode(%Date{year: y, month: m, day: d}) do
    pad4(y) <> pad2(m) <> pad2(d)
  end

  def encode(%__MODULE__{year: y, month: nil}) do
    pad4(y)
  end

  def encode(%__MODULE__{year: y, month: m, day: nil}) do
    pad4(y) <> pad2(m)
  end

  def encode(%__MODULE__{year: y, month: m, day: d}) do
    pad4(y) <> pad2(m) <> pad2(d)
  end

  defp pad4(n), do: n |> Integer.to_string() |> String.pad_leading(4, "0")
  defp pad2(n), do: n |> Integer.to_string() |> String.pad_leading(2, "0")
end
