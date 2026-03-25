defmodule HL7v2.Segment.LOC do
  @moduledoc """
  Location Identification (LOC) segment -- HL7v2 v2.5.1.

  Contains location identification information.
  9 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "LOC",
    fields: [
      {1, :primary_key_value, HL7v2.Type.PL, :r, 1},
      {2, :location_description, HL7v2.Type.ST, :o, 1},
      {3, :location_type, HL7v2.Type.IS, :o, :unbounded},
      {4, :organization_name_loc, HL7v2.Type.XON, :o, :unbounded},
      {5, :location_address, HL7v2.Type.XAD, :o, :unbounded},
      {6, :location_phone, HL7v2.Type.XTN, :o, :unbounded},
      {7, :license_number, HL7v2.Type.CE, :o, :unbounded},
      {8, :location_equipment, HL7v2.Type.IS, :o, :unbounded},
      {9, :location_service_code, HL7v2.Type.IS, :o, 1}
    ]
end
