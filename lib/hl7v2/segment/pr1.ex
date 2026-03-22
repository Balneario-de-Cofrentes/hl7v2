defmodule HL7v2.Segment.PR1 do
  @moduledoc """
  Procedures (PR1) segment — HL7v2 v2.5.1.

  Contains information about a procedure performed on a patient.
  20 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "PR1",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :r, 1},
      {2, :procedure_coding_method, HL7v2.Type.IS, :b, 1},
      {3, :procedure_code, HL7v2.Type.CE, :r, 1},
      {4, :procedure_description, HL7v2.Type.ST, :b, 1},
      {5, :procedure_date_time, HL7v2.Type.TS, :r, 1},
      {6, :procedure_functional_type, HL7v2.Type.IS, :o, 1},
      {7, :procedure_minutes, HL7v2.Type.NM, :o, 1},
      {8, :anesthesiologist, HL7v2.Type.XCN, :b, :unbounded},
      {9, :anesthesia_code, HL7v2.Type.IS, :o, 1},
      {10, :anesthesia_minutes, HL7v2.Type.NM, :o, 1},
      {11, :surgeon, HL7v2.Type.XCN, :b, :unbounded},
      {12, :procedure_practitioner, HL7v2.Type.XCN, :b, :unbounded},
      {13, :consent_code, HL7v2.Type.CE, :o, 1},
      {14, :procedure_priority, HL7v2.Type.ID, :o, 1},
      {15, :associated_diagnosis_code, HL7v2.Type.CE, :o, 1},
      {16, :procedure_code_modifier, HL7v2.Type.CE, :o, :unbounded},
      {17, :procedure_drg_type, HL7v2.Type.IS, :o, 1},
      {18, :tissue_type_code, HL7v2.Type.CE, :o, :unbounded},
      {19, :procedure_identifier, HL7v2.Type.EI, :o, 1},
      {20, :procedure_action_code, HL7v2.Type.ID, :o, 1}
    ]
end
