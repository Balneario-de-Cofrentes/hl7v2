defmodule HL7v2.Segment.DG1 do
  @moduledoc """
  Diagnosis (DG1) segment — HL7v2 v2.5.1.

  Contains patient diagnosis information.
  21 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "DG1",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :r, 1},
      {2, :diagnosis_coding_method, HL7v2.Type.ID, :b, 1},
      {3, :diagnosis_code, HL7v2.Type.CE, :o, 1},
      {4, :diagnosis_description, HL7v2.Type.ST, :b, 1},
      {5, :diagnosis_date_time, HL7v2.Type.TS, :o, 1},
      {6, :diagnosis_type, HL7v2.Type.IS, :r, 1},
      {7, :major_diagnostic_category, HL7v2.Type.CE, :b, 1},
      {8, :diagnostic_related_group, HL7v2.Type.CE, :b, 1},
      {9, :drg_approval_indicator, HL7v2.Type.ID, :b, 1},
      {10, :drg_grouper_review_code, HL7v2.Type.IS, :b, 1},
      {11, :outlier_type, HL7v2.Type.CE, :b, 1},
      {12, :outlier_days, HL7v2.Type.NM, :b, 1},
      {13, :outlier_cost, :raw, :b, 1},
      {14, :grouper_version_and_type, HL7v2.Type.ST, :b, 1},
      {15, :diagnosis_priority, HL7v2.Type.ID, :o, 1},
      {16, :diagnosing_clinician, :raw, :o, :unbounded},
      {17, :diagnosis_classification, HL7v2.Type.IS, :o, 1},
      {18, :confidential_indicator, HL7v2.Type.ID, :o, 1},
      {19, :attestation_date_time, HL7v2.Type.TS, :o, 1},
      {20, :diagnosis_identifier, HL7v2.Type.EI, :c, 1},
      {21, :diagnosis_action_code, HL7v2.Type.ID, :c, 1}
    ]
end
