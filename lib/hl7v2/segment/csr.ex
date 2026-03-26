defmodule HL7v2.Segment.CSR do
  @moduledoc """
  Clinical Study Registration (CSR) segment -- HL7v2 v2.5.1.

  Contains patient registration information for a clinical study.
  16 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "CSR",
    fields: [
      {1, :sponsor_study_id, HL7v2.Type.EI, :r, 1},
      {2, :alternate_study_id, HL7v2.Type.EI, :o, 1},
      {3, :institution_registering_the_patient, HL7v2.Type.CE, :o, 1},
      {4, :sponsor_patient_id, HL7v2.Type.CX, :r, 1},
      {5, :alternate_patient_id, HL7v2.Type.CX, :o, 1},
      {6, :date_time_of_patient_study_registration, HL7v2.Type.TS, :o, 1},
      {7, :person_performing_study_registration, HL7v2.Type.XCN, :o, :unbounded},
      {8, :study_authorizing_provider, HL7v2.Type.XCN, :r, :unbounded},
      {9, :date_time_patient_study_consent_signed, HL7v2.Type.TS, :o, 1},
      {10, :patient_study_eligibility_status, HL7v2.Type.CE, :c, 1},
      {11, :study_randomization_date_time, HL7v2.Type.TS, :o, :unbounded},
      {12, :randomized_study_arm, HL7v2.Type.CE, :o, :unbounded},
      {13, :stratum_for_study_randomization, HL7v2.Type.CE, :o, :unbounded},
      {14, :patient_evaluability_status, HL7v2.Type.CE, :c, 1},
      {15, :date_time_ended_study, HL7v2.Type.TS, :o, 1},
      {16, :reason_ended_study, HL7v2.Type.CE, :o, 1}
    ]
end
