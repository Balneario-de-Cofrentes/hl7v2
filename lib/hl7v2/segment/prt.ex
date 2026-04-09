defmodule HL7v2.Segment.PRT do
  @moduledoc """
  Participation Information (PRT) segment — HL7v2 v2.7+.

  Introduced in HL7 v2.7 to replace ROL in many messages. Captures the
  participation of a person, organization, location, device, or other
  entity in an event (e.g., ordering provider, performing lab, specimen
  collector).

  10 fields per HL7 v2.7 specification.
  """

  use HL7v2.Segment,
    id: "PRT",
    fields: [
      {1, :participation_instance_id, HL7v2.Type.EI, :o, 1},
      {2, :action_code, HL7v2.Type.ID, :r, 1},
      {3, :action_reason, HL7v2.Type.CWE, :o, 1},
      {4, :participation, HL7v2.Type.CWE, :r, 1},
      {5, :participation_person, HL7v2.Type.XCN, :o, :unbounded},
      {6, :participation_person_provider_type, HL7v2.Type.CWE, :o, 1},
      {7, :participant_organization_unit_type, HL7v2.Type.CWE, :o, 1},
      {8, :participation_organization, HL7v2.Type.XON, :o, :unbounded},
      {9, :participant_location, HL7v2.Type.PL, :o, :unbounded},
      {10, :participation_device, HL7v2.Type.EI, :o, :unbounded}
    ]
end
