defmodule HL7v2.Segment.BTX do
  @moduledoc """
  Blood Product Transfusion/Disposition (BTX) segment -- HL7v2 v2.5.1.

  Contains blood product transfusion and disposition information.
  20 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "BTX",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :r, 1},
      {2, :bc_donation_id, HL7v2.Type.EI, :c, 1},
      {3, :bc_component, HL7v2.Type.CNE, :c, 1},
      {4, :bc_blood_group, HL7v2.Type.CNE, :o, 1},
      {5, :cp_commercial_product, HL7v2.Type.CWE, :c, 1},
      {6, :cp_manufacturer, HL7v2.Type.XON, :c, 1},
      {7, :cp_lot_number, HL7v2.Type.EI, :c, 1},
      {8, :bp_quantity, HL7v2.Type.NM, :r, 1},
      {9, :bp_amount, HL7v2.Type.NM, :o, 1},
      {10, :bp_units, HL7v2.Type.CE, :o, 1},
      {11, :bp_transfusion_disposition_status, HL7v2.Type.CWE, :r, 1},
      {12, :bp_message_status, HL7v2.Type.ID, :r, 1},
      {13, :bp_date_time_of_status, HL7v2.Type.TS, :r, 1},
      {14, :bp_administrator, HL7v2.Type.XCN, :o, 1},
      {15, :bp_verifier, HL7v2.Type.XCN, :o, 1},
      {16, :bp_transfusion_start_date_time_of_status, HL7v2.Type.TS, :o, 1},
      {17, :bp_transfusion_end_date_time_of_status, HL7v2.Type.TS, :o, 1},
      {18, :bp_adverse_reaction_type, HL7v2.Type.CWE, :o, :unbounded},
      {19, :bp_transfusion_interrupted_reason, HL7v2.Type.CWE, :o, 1},
      {20, :bp_unique_id, HL7v2.Type.EI, :c, 1}
    ]
end
