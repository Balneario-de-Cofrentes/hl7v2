defmodule HL7v2.Segment.BPX do
  @moduledoc """
  Blood Product Dispense Status (BPX) segment -- HL7v2 v2.5.1.

  Contains blood product dispense status information.
  21 fields per HL7 v2.5.1 specification. Fields 1-15 are typed,
  fields 16-21 use :raw.
  """

  use HL7v2.Segment,
    id: "BPX",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :r, 1},
      {2, :bp_dispense_status, HL7v2.Type.CWE, :r, 1},
      {3, :bp_status, HL7v2.Type.ID, :r, 1},
      {4, :bp_date_time_of_status, HL7v2.Type.TS, :r, 1},
      {5, :bc_donation_id, HL7v2.Type.EI, :c, 1},
      {6, :bc_component, HL7v2.Type.CNE, :c, 1},
      {7, :bc_donation_type_intended, HL7v2.Type.CNE, :o, 1},
      {8, :cp_commercial_product, HL7v2.Type.CWE, :c, 1},
      {9, :cp_manufacturer, HL7v2.Type.XON, :c, 1},
      {10, :cp_lot_number, HL7v2.Type.EI, :c, 1},
      {11, :bp_blood_group, HL7v2.Type.CNE, :o, 1},
      {12, :bc_special_testing, HL7v2.Type.CNE, :o, :unbounded},
      {13, :bp_expiration_date_time, HL7v2.Type.TS, :o, 1},
      {14, :bp_quantity, HL7v2.Type.NM, :r, 1},
      {15, :bp_amount, HL7v2.Type.NM, :o, 1},
      {16, :field_16, :raw, :o, 1},
      {17, :field_17, :raw, :o, 1},
      {18, :field_18, :raw, :o, 1},
      {19, :field_19, :raw, :o, 1},
      {20, :field_20, :raw, :o, 1},
      {21, :field_21, :raw, :o, 1}
    ]
end
