defmodule HL7v2.Segment.ARV do
  @moduledoc """
  Access Restriction (ARV) segment — HL7v2 v2.6+.

  Introduced in HL7 v2.6 to capture access restrictions (e.g., "break
  the glass" emergency access, patient-requested confidentiality, VIP).

  7 fields per HL7 v2.6 specification.
  """

  use HL7v2.Segment,
    id: "ARV",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :o, 1},
      {2, :access_restriction_action_code, HL7v2.Type.CNE, :r, 1},
      {3, :access_restriction_value, HL7v2.Type.CWE, :o, 1},
      {4, :access_restriction_reason, HL7v2.Type.CWE, :o, :unbounded},
      {5, :special_access_restriction_instructions, HL7v2.Type.ST, :o, :unbounded},
      {6, :access_restriction_date_range, HL7v2.Type.DR, :o, 1},
      {7, :access_restriction_recipient, HL7v2.Type.CWE, :o, :unbounded}
    ]
end
