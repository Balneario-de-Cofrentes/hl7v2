defmodule HL7v2.Segment.RXR do
  @moduledoc """
  Pharmacy/Treatment Route (RXR) segment — HL7v2 v2.5.1.

  Describes how a medication is administered (route, site, device, method).
  6 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "RXR",
    fields: [
      {1, :route, HL7v2.Type.CE, :r, 1},
      {2, :administration_site, HL7v2.Type.CWE, :o, 1},
      {3, :administration_device, HL7v2.Type.CE, :o, 1},
      {4, :administration_method, HL7v2.Type.CWE, :o, 1},
      {5, :routing_instruction, HL7v2.Type.CE, :o, 1},
      {6, :administration_site_modifier, HL7v2.Type.CWE, :o, 1}
    ]
end
