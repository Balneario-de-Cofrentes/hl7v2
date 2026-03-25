defmodule HL7v2.Segment.ABS do
  @moduledoc """
  Abstract (ABS) segment -- HL7v2 v2.5.1.

  Contains abstracting information related to a patient's encounter.

  13 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "ABS",
    fields: [
      {1, :discharge_care_provider, HL7v2.Type.XCN, :o, 1},
      {2, :transfer_medical_service_code, HL7v2.Type.CE, :o, 1},
      {3, :severity_of_illness_code, HL7v2.Type.CE, :o, 1},
      {4, :date_time_of_attestation, HL7v2.Type.TS, :o, 1},
      {5, :attested_by, HL7v2.Type.XCN, :o, 1},
      {6, :triage_code, HL7v2.Type.CE, :o, 1},
      {7, :abstract_completion_date_time, HL7v2.Type.TS, :o, 1},
      {8, :abstracted_by, HL7v2.Type.XCN, :o, 1},
      {9, :case_category_code, HL7v2.Type.CE, :o, 1},
      {10, :caesarian_section_indicator, HL7v2.Type.ID, :o, 1},
      {11, :gestation_category_code, HL7v2.Type.CE, :o, 1},
      {12, :gestation_period_weeks, HL7v2.Type.NM, :o, 1},
      {13, :newborn_code, HL7v2.Type.CE, :o, 1}
    ]
end
