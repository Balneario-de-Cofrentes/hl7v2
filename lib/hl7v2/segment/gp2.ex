defmodule HL7v2.Segment.GP2 do
  @moduledoc """
  Grouping/Reimbursement — Procedure Line Item (GP2) segment — HL7v2 v2.5.1.

  Contains grouping and reimbursement information at the procedure line-item level.
  First 10 fields are typed; remaining fields use `:raw` for lossless round-trip.

  14 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "GP2",
    fields: [
      {1, :revenue_code, HL7v2.Type.IS, :o, 1},
      {2, :number_of_service_units, HL7v2.Type.NM, :o, 1},
      {3, :charge, HL7v2.Type.CP, :o, 1},
      {4, :reimbursement_action_code, HL7v2.Type.IS, :o, 1},
      {5, :denial_or_rejection_code, HL7v2.Type.IS, :o, 1},
      {6, :oce_edit_code, HL7v2.Type.IS, :o, :unbounded},
      {7, :ambulatory_payment_classification_code, HL7v2.Type.CE, :o, 1},
      {8, :modifier_edit_code, HL7v2.Type.IS, :o, :unbounded},
      {9, :payment_adjustment_code, HL7v2.Type.IS, :o, 1},
      {10, :packaging_status_code, HL7v2.Type.IS, :o, 1},
      {11, :field_11, :raw, :o, 1},
      {12, :field_12, :raw, :o, 1},
      {13, :field_13, :raw, :o, 1},
      {14, :field_14, :raw, :o, 1}
    ]
end
