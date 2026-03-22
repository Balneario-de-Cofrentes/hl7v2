defmodule HL7v2.Type.PL do
  @moduledoc """
  Person Location (PL) -- HL7v2 composite data type.

  Used to specify patient location (point of care, room, bed, facility, etc.).

  11 components:
  1. Point of Care (IS) -- Table 0302
  2. Room (IS) -- Table 0303
  3. Bed (IS) -- Table 0304
  4. Facility (HD) -- sub-components delimited by `&`
  5. Location Status (IS) -- Table 0306
  6. Person Location Type (IS) -- Table 0305: C=Clinic, N=Nursing, etc.
  7. Building (IS) -- Table 0307
  8. Floor (IS) -- Table 0308
  9. Location Description (ST)
  10. Comprehensive Location Identifier (EI) -- sub-components delimited by `&`
  11. Assigning Authority for Location (HD) -- sub-components delimited by `&`
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.{HD, EI}

  defstruct [
    :point_of_care,
    :room,
    :bed,
    :facility,
    :location_status,
    :person_location_type,
    :building,
    :floor,
    :location_description,
    :comprehensive_location_identifier,
    :assigning_authority_for_location
  ]

  @type t :: %__MODULE__{
          point_of_care: binary() | nil,
          room: binary() | nil,
          bed: binary() | nil,
          facility: HD.t() | nil,
          location_status: binary() | nil,
          person_location_type: binary() | nil,
          building: binary() | nil,
          floor: binary() | nil,
          location_description: binary() | nil,
          comprehensive_location_identifier: EI.t() | nil,
          assigning_authority_for_location: HD.t() | nil
        }

  @doc """
  Parses a PL from a list of components.

  ## Examples

      iex> HL7v2.Type.PL.parse(["ICU", "101", "A", "HOSP&2.16.840.1.113883.19.4.6&ISO", "", "N"])
      %HL7v2.Type.PL{
        point_of_care: "ICU",
        room: "101",
        bed: "A",
        facility: %HL7v2.Type.HD{namespace_id: "HOSP", universal_id: "2.16.840.1.113883.19.4.6", universal_id_type: "ISO"},
        person_location_type: "N"
      }

      iex> HL7v2.Type.PL.parse([])
      %HL7v2.Type.PL{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      point_of_care: Type.get_component(components, 0),
      room: Type.get_component(components, 1),
      bed: Type.get_component(components, 2),
      facility: Type.parse_sub(HD, Type.get_component(components, 3)),
      location_status: Type.get_component(components, 4),
      person_location_type: Type.get_component(components, 5),
      building: Type.get_component(components, 6),
      floor: Type.get_component(components, 7),
      location_description: Type.get_component(components, 8),
      comprehensive_location_identifier: Type.parse_sub(EI, Type.get_component(components, 9)),
      assigning_authority_for_location: Type.parse_sub(HD, Type.get_component(components, 10))
    }
  end

  @doc """
  Encodes a PL to a list of component strings.

  ## Examples

      iex> HL7v2.Type.PL.encode(%HL7v2.Type.PL{point_of_care: "ICU", facility: %HL7v2.Type.HD{namespace_id: "HOSP"}})
      ["ICU", "", "", "HOSP"]

      iex> HL7v2.Type.PL.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = pl) do
    [
      pl.point_of_care || "",
      pl.room || "",
      pl.bed || "",
      Type.encode_sub(HD, pl.facility),
      pl.location_status || "",
      pl.person_location_type || "",
      pl.building || "",
      pl.floor || "",
      pl.location_description || "",
      Type.encode_sub(EI, pl.comprehensive_location_identifier),
      Type.encode_sub(HD, pl.assigning_authority_for_location)
    ]
    |> Type.trim_trailing()
  end

end
