defmodule HL7v2.Segment.OVR do
  @moduledoc """
  Override Segment (OVR) -- HL7v2 v2.5.1.

  Contains override information for business rule violations.
  5 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "OVR",
    fields: [
      {1, :business_rule_override_type, HL7v2.Type.CWE, :o, 1},
      {2, :business_rule_override_code, HL7v2.Type.CWE, :o, 1},
      {3, :override_comments, HL7v2.Type.TX, :o, 1},
      {4, :override_entered_by, HL7v2.Type.XCN, :o, 1},
      {5, :override_authorized_by, HL7v2.Type.XCN, :o, 1}
    ]
end
