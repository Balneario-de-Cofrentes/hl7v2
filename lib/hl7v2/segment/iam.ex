defmodule HL7v2.Segment.IAM do
  @moduledoc """
  Patient Adverse Reaction Information (IAM) segment -- HL7v2 v2.5.1.

  Records allergy/adverse reaction information with richer detail than AL1.
  20 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "IAM",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :r, 1},
      {2, :allergen_type_code, HL7v2.Type.CE, :o, 1},
      {3, :allergen_code_mnemonic_description, HL7v2.Type.CE, :r, 1},
      {4, :allergy_severity_code, HL7v2.Type.CE, :o, 1},
      {5, :allergy_reaction_code, HL7v2.Type.ST, :o, :unbounded},
      {6, :allergy_action_code, HL7v2.Type.CNE, :r, 1},
      {7, :allergy_unique_identifier, HL7v2.Type.EI, :o, 1},
      {8, :action_reason, HL7v2.Type.ST, :o, 1},
      {9, :sensitivity_to_causative_agent_code, HL7v2.Type.CE, :o, 1},
      {10, :allergen_group_code_mnemonic_description, HL7v2.Type.CE, :o, 1},
      {11, :onset_date, HL7v2.Type.DT, :o, 1},
      {12, :onset_date_text, HL7v2.Type.ST, :o, 1},
      {13, :reported_date_time, HL7v2.Type.TS, :o, 1},
      {14, :reported_by, HL7v2.Type.XPN, :o, 1},
      {15, :relationship_to_patient_code, HL7v2.Type.CE, :o, 1},
      {16, :alert_device_code, HL7v2.Type.CE, :o, 1},
      {17, :allergy_clinical_status_code, HL7v2.Type.CE, :o, 1},
      {18, :statused_by_person, HL7v2.Type.XCN, :o, 1},
      {19, :statused_by_organization, HL7v2.Type.XON, :o, 1},
      {20, :statused_at_date_time, HL7v2.Type.TS, :o, 1}
    ]
end
