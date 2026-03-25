defmodule HL7v2.Segment.LCH do
  @moduledoc """
  Location Characteristic (LCH) segment -- HL7v2 v2.5.1.

  Contains characteristics of a location.
  5 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "LCH",
    fields: [
      {1, :primary_key_value, HL7v2.Type.PL, :r, 1},
      {2, :segment_unique_key, HL7v2.Type.EI, :o, 1},
      {3, :location_characteristic_id, HL7v2.Type.CE, :r, 1},
      {4, :location_characteristic_value, HL7v2.Type.CE, :r, 1}
    ]
end
