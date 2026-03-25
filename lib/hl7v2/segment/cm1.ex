defmodule HL7v2.Segment.CM1 do
  @moduledoc """
  Clinical Study Phase Master (CM1) segment — HL7v2 v2.5.1.

  Contains phase-level information for a clinical study.

  3 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "CM1",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :r, 1},
      {2, :study_phase_identifier, HL7v2.Type.CE, :r, 1},
      {3, :description_of_study_phase, HL7v2.Type.ST, :r, 1}
    ]
end
