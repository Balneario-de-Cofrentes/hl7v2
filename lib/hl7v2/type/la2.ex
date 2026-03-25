defmodule HL7v2.Type.LA2 do
  @moduledoc """
  Location with Address Variation 2 (LA2) -- HL7v2 composite data type.

  Specifies a patient location with full address details. Used for
  administered-at locations (RXA-11).

  14 components:
  1. Point of Care (IS)
  2. Room (IS)
  3. Bed (IS)
  4. Facility (HD) -- sub-components
  5. Location Status (IS)
  6. Patient Location Type (IS)
  7. Building (IS)
  8. Floor (IS)
  9. Street Address (ST)
  10. Other Designation (ST)
  11. City (ST)
  12. State or Province (ST)
  13. Zip or Postal Code (ST)
  14. Country (ID) -- Table 0399
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.HD

  defstruct [
    :point_of_care,
    :room,
    :bed,
    :facility,
    :location_status,
    :patient_location_type,
    :building,
    :floor,
    :street_address,
    :other_designation,
    :city,
    :state_or_province,
    :zip_or_postal_code,
    :country
  ]

  @type t :: %__MODULE__{
          point_of_care: binary() | nil,
          room: binary() | nil,
          bed: binary() | nil,
          facility: HD.t() | nil,
          location_status: binary() | nil,
          patient_location_type: binary() | nil,
          building: binary() | nil,
          floor: binary() | nil,
          street_address: binary() | nil,
          other_designation: binary() | nil,
          city: binary() | nil,
          state_or_province: binary() | nil,
          zip_or_postal_code: binary() | nil,
          country: binary() | nil
        }

  @doc """
  Parses an LA2 from a list of components.

  ## Examples

      iex> HL7v2.Type.LA2.parse(["ICU", "101", "A"])
      %HL7v2.Type.LA2{point_of_care: "ICU", room: "101", bed: "A"}

      iex> HL7v2.Type.LA2.parse([])
      %HL7v2.Type.LA2{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      point_of_care: Type.get_component(components, 0),
      room: Type.get_component(components, 1),
      bed: Type.get_component(components, 2),
      facility: Type.parse_sub(HD, Type.get_component(components, 3)),
      location_status: Type.get_component(components, 4),
      patient_location_type: Type.get_component(components, 5),
      building: Type.get_component(components, 6),
      floor: Type.get_component(components, 7),
      street_address: Type.get_component(components, 8),
      other_designation: Type.get_component(components, 9),
      city: Type.get_component(components, 10),
      state_or_province: Type.get_component(components, 11),
      zip_or_postal_code: Type.get_component(components, 12),
      country: Type.get_component(components, 13)
    }
  end

  @doc """
  Encodes an LA2 to a list of component strings.

  ## Examples

      iex> HL7v2.Type.LA2.encode(%HL7v2.Type.LA2{point_of_care: "ICU", room: "101", bed: "A"})
      ["ICU", "101", "A"]

      iex> HL7v2.Type.LA2.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = la2) do
    [
      la2.point_of_care || "",
      la2.room || "",
      la2.bed || "",
      Type.encode_sub(HD, la2.facility),
      la2.location_status || "",
      la2.patient_location_type || "",
      la2.building || "",
      la2.floor || "",
      la2.street_address || "",
      la2.other_designation || "",
      la2.city || "",
      la2.state_or_province || "",
      la2.zip_or_postal_code || "",
      la2.country || ""
    ]
    |> Type.trim_trailing()
  end
end
