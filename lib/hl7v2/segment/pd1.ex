defmodule HL7v2.Segment.PD1 do
  @moduledoc """
  Patient Additional Demographic (PD1) segment — HL7v2 v2.5.1.

  Contains additional patient demographic information not included in PID.
  21 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "PD1",
    fields: [
      {1, :living_dependency, HL7v2.Type.IS, :o, :unbounded},
      {2, :living_arrangement, HL7v2.Type.IS, :o, 1},
      {3, :patient_primary_facility, HL7v2.Type.XON, :o, :unbounded},
      {4, :patient_primary_care_provider_name_and_id_no, HL7v2.Type.XCN, :b, :unbounded},
      {5, :student_indicator, HL7v2.Type.IS, :o, 1},
      {6, :handicap, HL7v2.Type.IS, :o, 1},
      {7, :living_will_code, HL7v2.Type.IS, :o, 1},
      {8, :organ_donor_code, HL7v2.Type.IS, :o, 1},
      {9, :separate_bill, HL7v2.Type.ID, :o, 1},
      {10, :duplicate_patient, HL7v2.Type.CX, :o, :unbounded},
      {11, :publicity_code, HL7v2.Type.CE, :o, 1},
      {12, :protection_indicator, HL7v2.Type.ID, :o, 1},
      {13, :protection_indicator_effective_date, HL7v2.Type.DT, :o, 1},
      {14, :place_of_worship, HL7v2.Type.XON, :o, :unbounded},
      {15, :advance_directive_code, HL7v2.Type.CE, :o, :unbounded},
      {16, :immunization_registry_status, HL7v2.Type.IS, :o, 1},
      {17, :immunization_registry_status_effective_date, HL7v2.Type.DT, :o, 1},
      {18, :publicity_code_effective_date, HL7v2.Type.DT, :o, 1},
      {19, :military_branch, HL7v2.Type.IS, :o, 1},
      {20, :military_rank_grade, HL7v2.Type.IS, :o, 1},
      {21, :military_status, HL7v2.Type.IS, :o, 1}
    ]
end
