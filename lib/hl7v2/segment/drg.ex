defmodule HL7v2.Segment.DRG do
  @moduledoc """
  Diagnosis Related Group (DRG) segment — HL7v2 v2.5.1.

  Contains DRG grouping information for a patient encounter, including
  outlier information and approval status.

  11 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "DRG",
    fields: [
      {1, :diagnostic_related_group, HL7v2.Type.CE, :o, 1},
      {2, :drg_assigned_date_time, HL7v2.Type.TS, :o, 1},
      {3, :drg_approval_indicator, HL7v2.Type.ID, :o, 1},
      {4, :drg_grouper_review_code, HL7v2.Type.IS, :o, 1},
      {5, :outlier_type, HL7v2.Type.CE, :o, 1},
      {6, :outlier_days, HL7v2.Type.NM, :o, 1},
      {7, :outlier_cost, HL7v2.Type.CP, :o, 1},
      {8, :drg_payor, HL7v2.Type.IS, :o, 1},
      {9, :outlier_reimbursement, HL7v2.Type.CP, :o, 1},
      {10, :confidential_indicator, HL7v2.Type.ID, :o, 1},
      {11, :drg_transfer_type, HL7v2.Type.IS, :o, 1}
    ]
end
