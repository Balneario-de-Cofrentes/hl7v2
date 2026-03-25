defmodule HL7v2.Type.LA1 do
  @moduledoc """
  Location with Address Variation 1 (LA1) -- HL7v2 composite data type.

  Specifies a patient location with an optional address. Used for dispense-to
  and deliver-to locations in pharmacy segments.

  9 components:
  1. Point of Care (IS)
  2. Room (IS)
  3. Bed (IS)
  4. Facility (HD) -- sub-components
  5. Location Status (IS)
  6. Patient Location Type (IS)
  7. Building (IS)
  8. Floor (IS)
  9. Address (AD) -- sub-components (street, city, state, zip, country, type)
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
    :address
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
          address: binary() | nil
        }

  @doc """
  Parses an LA1 from a list of components.

  ## Examples

      iex> HL7v2.Type.LA1.parse(["ICU", "101", "A"])
      %HL7v2.Type.LA1{point_of_care: "ICU", room: "101", bed: "A"}

      iex> HL7v2.Type.LA1.parse([])
      %HL7v2.Type.LA1{}

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
      address: Type.get_component(components, 8)
    }
  end

  @doc """
  Encodes an LA1 to a list of component strings.

  ## Examples

      iex> HL7v2.Type.LA1.encode(%HL7v2.Type.LA1{point_of_care: "ICU", room: "101", bed: "A"})
      ["ICU", "101", "A"]

      iex> HL7v2.Type.LA1.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = la1) do
    [
      la1.point_of_care || "",
      la1.room || "",
      la1.bed || "",
      Type.encode_sub(HD, la1.facility),
      la1.location_status || "",
      la1.patient_location_type || "",
      la1.building || "",
      la1.floor || "",
      la1.address || ""
    ]
    |> Type.trim_trailing()
  end
end
