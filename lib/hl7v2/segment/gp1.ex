defmodule HL7v2.Segment.GP1 do
  @moduledoc """
  Grouping/Reimbursement — Visit (GP1) segment — HL7v2 v2.5.1.

  Contains grouping and reimbursement information at the visit level.

  5 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "GP1",
    fields: [
      {1, :type_of_bill_code, HL7v2.Type.IS, :r, 1},
      {2, :revenue_code, HL7v2.Type.IS, :o, :unbounded},
      {3, :overall_claim_disposition_code, HL7v2.Type.IS, :o, 1},
      {4, :oce_edits_per_visit_code, HL7v2.Type.IS, :o, :unbounded},
      {5, :outlier_cost, HL7v2.Type.CP, :o, 1}
    ]
end
