defmodule HL7v2.Segment.RQD do
  @moduledoc """
  Requisition Detail (RQD) segment -- HL7v2 v2.5.1.

  Contains requisition detail information.
  10 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "RQD",
    fields: [
      {1, :requisition_line_number, HL7v2.Type.SI, :o, 1},
      {2, :item_code_internal, HL7v2.Type.CE, :o, 1},
      {3, :item_code_external, HL7v2.Type.CE, :o, 1},
      {4, :hospital_item_code, HL7v2.Type.CE, :o, 1},
      {5, :requisition_quantity, HL7v2.Type.NM, :o, 1},
      {6, :requisition_unit_of_measure, HL7v2.Type.CE, :o, 1},
      {7, :dept_cost_center, HL7v2.Type.IS, :o, 1},
      {8, :item_natural_account_code, HL7v2.Type.IS, :o, 1},
      {9, :deliver_to_id, HL7v2.Type.CE, :o, 1},
      {10, :date_needed, HL7v2.Type.DT, :o, 1}
    ]
end
