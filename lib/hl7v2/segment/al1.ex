defmodule HL7v2.Segment.AL1 do
  @moduledoc """
  Patient Allergy Information (AL1) segment — HL7v2 v2.5.1.

  Records allergy information for a patient.
  6 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "AL1",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :r, 1},
      {2, :allergen_type_code, HL7v2.Type.CE, :o, 1},
      {3, :allergen_code, HL7v2.Type.CE, :r, 1},
      {4, :allergy_severity_code, HL7v2.Type.CE, :o, 1},
      {5, :allergy_reaction_code, HL7v2.Type.ST, :o, :unbounded},
      {6, :identification_date, HL7v2.Type.DT, :b, 1}
    ]
end
