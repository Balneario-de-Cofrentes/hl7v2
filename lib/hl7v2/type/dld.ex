defmodule HL7v2.Type.DLD do
  @moduledoc """
  Discharge to Location and Date (DLD) -- HL7v2 composite data type.

  Used to convey the location where a patient is discharged to and the
  effective date of discharge.

  2 components:
  1. Discharge to Location (IS) -- Table 0113
  2. Effective Date (TS) -- sub-components delimited by `&`
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.TS

  defstruct [:discharge_to_location, :effective_date]

  @type t :: %__MODULE__{
          discharge_to_location: binary() | nil,
          effective_date: TS.t() | nil
        }

  @doc """
  Parses a DLD from a list of components.

  ## Examples

      iex> HL7v2.Type.DLD.parse(["HOME"])
      %HL7v2.Type.DLD{discharge_to_location: "HOME"}

      iex> HL7v2.Type.DLD.parse(["HOME", "20260322"])
      %HL7v2.Type.DLD{discharge_to_location: "HOME", effective_date: %HL7v2.Type.TS{time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22}}}

      iex> HL7v2.Type.DLD.parse([])
      %HL7v2.Type.DLD{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      discharge_to_location: Type.get_component(components, 0),
      effective_date: parse_sub_ts(Type.get_component(components, 1))
    }
  end

  @doc """
  Encodes a DLD to a list of component strings.

  ## Examples

      iex> HL7v2.Type.DLD.encode(%HL7v2.Type.DLD{discharge_to_location: "HOME"})
      ["HOME"]

      iex> HL7v2.Type.DLD.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = dld) do
    [
      dld.discharge_to_location || "",
      encode_sub_ts(dld.effective_date)
    ]
    |> Type.trim_trailing()
  end

  defp parse_sub_ts(nil), do: nil

  defp parse_sub_ts(value) when is_binary(value) do
    subs = String.split(value, Type.sub_component_separator())
    ts_val = TS.parse(subs)
    if ts_val.time == nil and ts_val.degree_of_precision == nil, do: nil, else: ts_val
  end

  defp encode_sub_ts(nil), do: ""

  defp encode_sub_ts(%TS{} = ts) do
    ts |> TS.encode() |> Enum.join(Type.sub_component_separator())
  end
end
