defmodule HL7v2.Segment.UB2 do
  @moduledoc """
  UB92 Data (UB2) segment — HL7v2 v2.5.1.

  Contains UB92 billing data including co-insurance, condition codes,
  covered/non-covered days, and various value/occurrence codes.

  17 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "UB2",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :o, 1},
      {2, :co_insurance_days, HL7v2.Type.ST, :o, 1},
      {3, :condition_code, HL7v2.Type.IS, :o, 7},
      {4, :covered_days, HL7v2.Type.ST, :o, 1},
      {5, :non_covered_days, HL7v2.Type.ST, :o, 1},
      {6, :value_amount_and_code, HL7v2.Type.UVC, :o, :unbounded},
      {7, :occurrence_code_and_date, HL7v2.Type.OCD, :o, :unbounded},
      {8, :occurrence_span_code_dates, HL7v2.Type.OSP, :o, :unbounded},
      {9, :ub92_locator_2_state, HL7v2.Type.ST, :o, 1},
      {10, :ub92_locator_11_state, HL7v2.Type.ST, :o, :unbounded},
      {11, :ub92_locator_31_national, HL7v2.Type.ST, :o, 1},
      {12, :document_control_number, HL7v2.Type.ST, :o, :unbounded},
      {13, :ub92_locator_49_national, HL7v2.Type.ST, :o, :unbounded},
      {14, :ub92_locator_56_state, HL7v2.Type.ST, :o, :unbounded},
      {15, :ub92_locator_57_national, HL7v2.Type.ST, :o, 1},
      {16, :ub92_locator_78_state, HL7v2.Type.ST, :o, :unbounded},
      {17, :special_visit_count, HL7v2.Type.NM, :o, 1}
    ]
end
