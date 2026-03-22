defmodule HL7v2.Segment.FT1 do
  @moduledoc """
  Financial Transaction (FT1) segment — HL7v2 v2.5.1.

  Contains financial transaction information.
  31 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "FT1",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :o, 1},
      {2, :transaction_id, HL7v2.Type.ST, :o, 1},
      {3, :transaction_batch_id, HL7v2.Type.ST, :o, 1},
      {4, :transaction_date, HL7v2.Type.DR, :r, 1},
      {5, :transaction_posting_date, HL7v2.Type.TS, :o, 1},
      {6, :transaction_type, HL7v2.Type.IS, :r, 1},
      {7, :transaction_code, HL7v2.Type.CE, :r, 1},
      {8, :transaction_description, HL7v2.Type.ST, :b, 1},
      {9, :transaction_description_alt, HL7v2.Type.ST, :b, 1},
      {10, :transaction_quantity, HL7v2.Type.NM, :o, 1},
      {11, :transaction_amount_extended, :raw, :o, 1},
      {12, :transaction_amount_unit, :raw, :o, 1},
      {13, :department_code, HL7v2.Type.CE, :o, 1},
      {14, :insurance_plan_id, HL7v2.Type.CE, :o, 1},
      {15, :insurance_amount, :raw, :o, 1},
      {16, :assigned_patient_location, HL7v2.Type.PL, :o, 1},
      {17, :fee_schedule, HL7v2.Type.IS, :o, 1},
      {18, :patient_type, HL7v2.Type.IS, :o, 1},
      {19, :diagnosis_code, HL7v2.Type.CE, :o, :unbounded},
      {20, :performed_by_code, HL7v2.Type.XCN, :o, :unbounded},
      {21, :ordered_by_code, HL7v2.Type.XCN, :o, :unbounded},
      {22, :unit_cost, :raw, :o, 1},
      {23, :filler_order_number, HL7v2.Type.EI, :o, 1},
      {24, :entered_by_code, HL7v2.Type.XCN, :o, :unbounded},
      {25, :procedure_code, HL7v2.Type.CE, :o, 1},
      {26, :procedure_code_modifier, HL7v2.Type.CE, :o, :unbounded},
      {27, :advanced_beneficiary_notice_code, HL7v2.Type.CE, :o, 1},
      {28, :medically_necessary_duplicate_procedure_reason, HL7v2.Type.CWE, :o, 1},
      {29, :ndc_code, HL7v2.Type.CNE, :o, 1},
      {30, :payment_reference_id, HL7v2.Type.CX, :o, 1},
      {31, :transaction_reference_key, HL7v2.Type.SI, :o, :unbounded}
    ]
end
