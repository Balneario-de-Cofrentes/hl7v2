defmodule HL7v2.Type.DR do
  @moduledoc """
  Date/Time Range (DR) -- HL7v2 composite data type.

  Two components: range start and range end, both TS (Time Stamp) type.
  When only a start is known, component 2 is null (open-ended range).
  When only an end is known, component 1 is null.
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.TS

  defstruct [:range_start, :range_end]

  @type t :: %__MODULE__{
          range_start: TS.t() | nil,
          range_end: TS.t() | nil
        }

  @doc """
  Parses a date/time range from a list of components.

  Each component is itself a TS, so sub-components within are split by `&`.
  In practice, most DR values carry only a DTM string per component.

  ## Examples

      iex> HL7v2.Type.DR.parse(["20260101", "20261231"])
      %HL7v2.Type.DR{
        range_start: %HL7v2.Type.TS{time: %HL7v2.Type.DTM{year: 2026, month: 1, day: 1}},
        range_end: %HL7v2.Type.TS{time: %HL7v2.Type.DTM{year: 2026, month: 12, day: 31}}
      }

      iex> HL7v2.Type.DR.parse([])
      %HL7v2.Type.DR{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      range_start: parse_ts_component(Type.get_component(components, 0)),
      range_end: parse_ts_component(Type.get_component(components, 1))
    }
  end

  @doc """
  Encodes a date/time range to a list of component strings.

  ## Examples

      iex> HL7v2.Type.DR.encode(%HL7v2.Type.DR{
      ...>   range_start: %HL7v2.Type.TS{time: %HL7v2.Type.DTM{year: 2026, month: 1, day: 1}},
      ...>   range_end: %HL7v2.Type.TS{time: %HL7v2.Type.DTM{year: 2026, month: 12, day: 31}}
      ...> })
      ["20260101", "20261231"]

      iex> HL7v2.Type.DR.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = dr) do
    [
      encode_ts_component(dr.range_start),
      encode_ts_component(dr.range_end)
    ]
    |> Type.trim_trailing()
  end

  # TS within DR: parse from a single string (the DTM value)
  defp parse_ts_component(nil), do: nil
  defp parse_ts_component(value), do: TS.parse([value])

  # Encode TS back to a single string for DR components
  defp encode_ts_component(nil), do: ""

  defp encode_ts_component(%TS{} = ts) do
    case TS.encode(ts) do
      [] -> ""
      [time_str | _] -> time_str
    end
  end
end
