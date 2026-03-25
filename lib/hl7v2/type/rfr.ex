defmodule HL7v2.Type.RFR do
  @moduledoc """
  Reference Range (RFR) -- HL7v2 composite data type.

  Specifies a reference range for an observation with optional demographic qualifiers.

  7 components:
  1. Numeric Range (NR) -- sub-components (low & high)
  2. Administrative Sex (IS) -- Table 0001
  3. Age Range (NR) -- sub-components
  4. Gestational Age Range (NR) -- sub-components
  5. Species (ST)
  6. Race/Subspecies (ST)
  7. Conditions (TX)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.NR

  defstruct [
    :numeric_range,
    :administrative_sex,
    :age_range,
    :gestational_age_range,
    :species,
    :race_subspecies,
    :conditions
  ]

  @type t :: %__MODULE__{
          numeric_range: NR.t() | nil,
          administrative_sex: binary() | nil,
          age_range: NR.t() | nil,
          gestational_age_range: NR.t() | nil,
          species: binary() | nil,
          race_subspecies: binary() | nil,
          conditions: binary() | nil
        }

  @doc """
  Parses an RFR from a list of components.

  ## Examples

      iex> HL7v2.Type.RFR.parse(["3.5&5.5", "M"])
      %HL7v2.Type.RFR{
        numeric_range: %HL7v2.Type.NR{
          low: %HL7v2.Type.NM{value: "3.5", original: "3.5"},
          high: %HL7v2.Type.NM{value: "5.5", original: "5.5"}
        },
        administrative_sex: "M"
      }

      iex> HL7v2.Type.RFR.parse([])
      %HL7v2.Type.RFR{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      numeric_range: Type.parse_sub(NR, Type.get_component(components, 0)),
      administrative_sex: Type.get_component(components, 1),
      age_range: Type.parse_sub(NR, Type.get_component(components, 2)),
      gestational_age_range: Type.parse_sub(NR, Type.get_component(components, 3)),
      species: Type.get_component(components, 4),
      race_subspecies: Type.get_component(components, 5),
      conditions: Type.get_component(components, 6)
    }
  end

  @doc """
  Encodes an RFR to a list of component strings.

  ## Examples

      iex> HL7v2.Type.RFR.encode(%HL7v2.Type.RFR{numeric_range: %HL7v2.Type.NR{low: %HL7v2.Type.NM{value: "3.5", original: "3.5"}, high: %HL7v2.Type.NM{value: "5.5", original: "5.5"}}, administrative_sex: "M"})
      ["3.5&5.5", "M"]

      iex> HL7v2.Type.RFR.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = rfr) do
    [
      Type.encode_sub(NR, rfr.numeric_range),
      rfr.administrative_sex || "",
      Type.encode_sub(NR, rfr.age_range),
      Type.encode_sub(NR, rfr.gestational_age_range),
      rfr.species || "",
      rfr.race_subspecies || "",
      rfr.conditions || ""
    ]
    |> Type.trim_trailing()
  end
end
