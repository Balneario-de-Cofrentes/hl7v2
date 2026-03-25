defmodule HL7v2.Segment.BTX do
  @moduledoc """
  Blood Product Transfusion/Disposition (BTX) segment -- HL7v2 v2.5.1.

  Contains blood product transfusion and disposition information.

  20 fields per HL7 v2.5.1 specification. Fields 1-15 are typed,
  fields 16-20 use :raw.
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
      {16, :field_16, :raw, :o, 1},
      {17, :field_17, :raw, :o, 1},
      {18, :field_18, :raw, :o, 1},
      {19, :field_19, :raw, :o, 1},
      {20, :field_20, :raw, :o, 1}
    ]
end
