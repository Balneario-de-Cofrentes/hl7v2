defmodule HL7v2.Segment.IAR do
  @moduledoc """
  Allergy Reaction (IAR) segment — HL7v2 v2.7+.

  Introduced in HL7 v2.7. Attaches to an IAM segment to provide
  additional reaction details (e.g., severity, onset time, treatment
  received) for a patient's adverse reaction.

  5 fields per HL7 v2.7 specification.
  """

  use HL7v2.Segment,
    id: "IAR",
    fields: [
      {1, :allergy_reaction_code, HL7v2.Type.CWE, :r, 1},
      {2, :allergy_severity_code, HL7v2.Type.CWE, :o, 1},
      {3, :sensitivity_to_causative_agent_code, HL7v2.Type.CWE, :o, 1},
      {4, :management, HL7v2.Type.ST, :o, 1},
      {5, :allergy_reaction_duration, HL7v2.Type.CQ, :o, 1}
    ]
end
