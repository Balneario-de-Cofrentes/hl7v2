defmodule HL7v2.Segment.STZ do
  @moduledoc """
  Sterilization Parameter (STZ) segment — HL7v2 v2.6+ (Chapter 17 Materials Management).

  Captures sterilization parameters for a reusable medical device cycle.
  Complements SCD (Anti-Microbial Cycle Data) and SCP (Sterilization
  Configuration).

  3 fields per HL7 v2.6 specification.
  """

  use HL7v2.Segment,
    id: "STZ",
    fields: [
      {1, :sterilization_type, HL7v2.Type.CWE, :r, 1},
      {2, :sterilization_cycle, HL7v2.Type.CWE, :o, 1},
      {3, :maintenance_cycle, HL7v2.Type.CWE, :o, 1}
    ]
end
