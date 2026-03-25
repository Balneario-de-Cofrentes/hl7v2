defmodule HL7v2.Segment.UB1 do
  @moduledoc """
  UB82 (UB1) segment — HL7v2 v2.5.1.

  Contains UB82 billing data. Most fields are backward-compatible (withdrawn
  in later versions but still present on the wire).

  23 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "UB1",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :o, 1},
      {2, :blood_deductible, HL7v2.Type.NM, :b, 1},
      {3, :blood_furnished_pints_of, HL7v2.Type.NM, :b, 1},
      {4, :blood_replaced_pints, HL7v2.Type.NM, :b, 1},
      {5, :blood_not_replaced_pints, HL7v2.Type.NM, :b, 1},
      {6, :co_insurance_days, HL7v2.Type.NM, :b, 1},
      {7, :condition_code, HL7v2.Type.IS, :o, 7},
      {8, :covered_days, HL7v2.Type.NM, :b, 1},
      {9, :non_covered_days, HL7v2.Type.NM, :b, 1},
      {10, :value_amount_and_code, HL7v2.Type.UVC, :b, :unbounded},
      {11, :number_of_grace_days, HL7v2.Type.NM, :b, 1},
      {12, :special_program_indicator, HL7v2.Type.CE, :b, 1},
      {13, :psro_ur_approval_indicator, HL7v2.Type.CE, :b, 1},
      {14, :priority, HL7v2.Type.ID, :o, 1},
      {15, :psro_ur_approved_stay_to, HL7v2.Type.DT, :b, 1},
      {16, :number_of_grace_days_16, HL7v2.Type.NM, :o, 1},
      {17, :admit_date, HL7v2.Type.DT, :b, 1},
      {18, :discharge_date, HL7v2.Type.DT, :b, 1},
      {19, :discharge_diagnosis, HL7v2.Type.CE, :b, 1},
      {20, :discharge_diagnosis_date, HL7v2.Type.DT, :b, 1},
      {21, :facility_id, HL7v2.Type.ST, :b, 1},
      {22, :health_plan_id, HL7v2.Type.IS, :b, 1},
      {23, :special_program_code, HL7v2.Type.ID, :b, 1}
    ]
end
