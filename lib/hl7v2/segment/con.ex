defmodule HL7v2.Segment.CON do
  @moduledoc """
  Consent (CON) segment -- HL7v2 v2.5.1.

  Contains consent information for a patient procedure or treatment.
  25 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "CON",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :r, 1},
      {2, :consent_type, HL7v2.Type.CWE, :o, 1},
      {3, :consent_form_id, HL7v2.Type.ST, :o, 1},
      {4, :consent_form_number, HL7v2.Type.EI, :o, 1},
      {5, :consent_text, HL7v2.Type.FT, :o, :unbounded},
      {6, :subject_specific_consent_text, HL7v2.Type.FT, :o, :unbounded},
      {7, :consent_background, HL7v2.Type.FT, :o, :unbounded},
      {8, :subject_specific_consent_background, HL7v2.Type.FT, :o, :unbounded},
      {9, :consenter_imposed_limitations, HL7v2.Type.FT, :o, :unbounded},
      {10, :consent_mode, HL7v2.Type.CNE, :o, 1},
      {11, :consent_status, HL7v2.Type.CNE, :r, 1},
      {12, :consent_discussion_date_time, HL7v2.Type.TS, :o, 1},
      {13, :consent_decision_date_time, HL7v2.Type.TS, :o, 1},
      {14, :consent_effective_date_time, HL7v2.Type.TS, :o, 1},
      {15, :consent_end_date_time, HL7v2.Type.TS, :o, 1},
      {16, :subject_competence_indicator, HL7v2.Type.ID, :o, 1},
      {17, :translator_assistance_indicator, HL7v2.Type.ID, :o, 1},
      {18, :language_translated_to, HL7v2.Type.ID, :o, 1},
      {19, :informational_material_supplied_indicator, HL7v2.Type.ID, :o, 1},
      {20, :consent_bypass_reason, HL7v2.Type.CWE, :o, 1},
      {21, :consent_disclosure_level, HL7v2.Type.ID, :o, 1},
      {22, :consent_non_disclosure_reason, HL7v2.Type.CWE, :o, 1},
      {23, :non_subject_consenter_reason, HL7v2.Type.CWE, :o, 1},
      {24, :consenter_id, HL7v2.Type.XPN, :r, :unbounded},
      {25, :relationship_to_subject_table, HL7v2.Type.IS, :r, :unbounded}
    ]
end
