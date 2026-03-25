defmodule HL7v2.Segment.LRL do
  @moduledoc """
  Location Relationship (LRL) segment -- HL7v2 v2.5.1.

  Contains relationship information between locations.
  6 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "LRL",
    fields: [
      {1, :primary_key_value, HL7v2.Type.PL, :r, 1},
      {2, :segment_unique_key, HL7v2.Type.EI, :o, 1},
      {3, :location_relationship_id, HL7v2.Type.CE, :r, 1},
      {4, :location_relationship_value, HL7v2.Type.XON, :o, :unbounded},
      {5, :organizational_location_relationship_value, HL7v2.Type.XAD, :o, :unbounded},
      {6, :patient_location_relationship_value, HL7v2.Type.PL, :o, 1}
    ]
end
