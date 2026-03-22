defmodule HL7v2.Type.TS do
  @moduledoc """
  Time Stamp (TS) -- HL7v2 composite data type.

  Legacy composite with 2 components: time (DTM format) and degree of precision.
  Retained for backward compatibility with v2.4 and earlier. In v2.5+, DTM is
  preferred for new fields.

  Component 2 (degree of precision) is deprecated. Values from Table 0529:
  Y (year), L (month), D (day), H (hour), M (minute), S (second).
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.DTM

  defstruct [:time, :degree_of_precision]

  @type t :: %__MODULE__{
          time: DTM.t() | nil,
          degree_of_precision: binary() | nil
        }

  @doc """
  Parses a timestamp from a list of components.

  ## Examples

      iex> HL7v2.Type.TS.parse(["20260322143022"])
      %HL7v2.Type.TS{time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22, hour: 14, minute: 30, second: 22}}

      iex> HL7v2.Type.TS.parse(["20260322", "D"])
      %HL7v2.Type.TS{time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22}, degree_of_precision: "D"}

      iex> HL7v2.Type.TS.parse([])
      %HL7v2.Type.TS{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      time: components |> Type.get_component(0) |> DTM.parse(),
      degree_of_precision: Type.get_component(components, 1)
    }
  end

  @doc """
  Encodes a timestamp to a list of component strings.

  ## Examples

      iex> HL7v2.Type.TS.encode(%HL7v2.Type.TS{time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22}})
      ["20260322"]

      iex> HL7v2.Type.TS.encode(%HL7v2.Type.TS{time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22}, degree_of_precision: "D"})
      ["20260322", "D"]

      iex> HL7v2.Type.TS.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = ts) do
    [
      DTM.encode(ts.time),
      ts.degree_of_precision || ""
    ]
    |> Type.trim_trailing()
  end
end
