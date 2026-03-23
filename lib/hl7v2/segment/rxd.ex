defmodule HL7v2.Segment.RXD do
  @moduledoc """
  Pharmacy/Treatment Dispense (RXD) segment — HL7v2 v2.5.1.

  Contains dispense information for a pharmacy/treatment order.
  33 fields per HL7 v2.5.1 specification; fields 1-20 typed, 21-33 raw.
  """

  use HL7v2.Segment,
    id: "RXD",
    fields: [
      {1, :dispense_sub_id_counter, HL7v2.Type.NM, :r, 1},
      {2, :dispense_give_code, HL7v2.Type.CE, :r, 1},
      {3, :date_time_dispensed, HL7v2.Type.TS, :r, 1},
      {4, :actual_dispense_amount, HL7v2.Type.NM, :r, 1},
      {5, :actual_dispense_units, HL7v2.Type.CE, :o, 1},
      {6, :actual_dosage_form, HL7v2.Type.CE, :o, 1},
      {7, :prescription_number, HL7v2.Type.ST, :r, 1},
      {8, :number_of_refills_remaining, HL7v2.Type.NM, :o, 1},
      {9, :dispense_notes, HL7v2.Type.ST, :o, :unbounded},
      {10, :dispensing_provider, HL7v2.Type.XCN, :o, :unbounded},
      {11, :substitution_status, HL7v2.Type.ID, :o, 1},
      {12, :total_daily_dose, HL7v2.Type.CQ, :o, 1},
      {13, :dispense_to_location, :raw, :o, 1},
      {14, :needs_human_review, HL7v2.Type.ID, :o, 1},
      {15, :pharmacy_treatment_suppliers_special_dispensing_instructions, HL7v2.Type.CE, :o,
       :unbounded},
      {16, :actual_strength, HL7v2.Type.NM, :o, 1},
      {17, :actual_strength_unit, HL7v2.Type.CE, :o, 1},
      {18, :substance_lot_number, HL7v2.Type.ST, :o, :unbounded},
      {19, :substance_expiration_date, HL7v2.Type.TS, :o, :unbounded},
      {20, :substance_manufacturer_name, HL7v2.Type.CE, :o, :unbounded},
      {21, :field_21, :raw, :o, 1},
      {22, :field_22, :raw, :o, 1},
      {23, :field_23, :raw, :o, 1},
      {24, :field_24, :raw, :o, 1},
      {25, :field_25, :raw, :o, 1},
      {26, :field_26, :raw, :o, 1},
      {27, :field_27, :raw, :o, 1},
      {28, :field_28, :raw, :o, 1},
      {29, :field_29, :raw, :o, 1},
      {30, :field_30, :raw, :o, 1},
      {31, :field_31, :raw, :o, 1},
      {32, :field_32, :raw, :o, 1},
      {33, :field_33, :raw, :o, 1}
    ]
end
