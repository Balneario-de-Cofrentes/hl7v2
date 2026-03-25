defmodule HL7v2.Segment.LCC do
  @moduledoc """
  Location Charge Code (LCC) segment -- HL7v2 v2.5.1.

  Contains charge code information associated with a location.
  4 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "LCC",
    fields: [
      {1, :primary_key_value, HL7v2.Type.PL, :r, 1},
      {2, :location_department, HL7v2.Type.CE, :r, 1},
      {3, :accommodation_type, HL7v2.Type.CE, :o, :unbounded},
      {4, :charge_code, HL7v2.Type.CE, :r, :unbounded}
    ]
end
