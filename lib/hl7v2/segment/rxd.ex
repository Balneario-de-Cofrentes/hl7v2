defmodule HL7v2.Segment.RXD do
  @moduledoc """
  Pharmacy/Treatment Dispense (RXD) segment — HL7v2 v2.5.1.

  Contains dispense information for a pharmacy/treatment order.
  33 fields per HL7 v2.5.1 specification.
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
      {13, :dispense_to_location, HL7v2.Type.LA1, :o, 1},
      {14, :needs_human_review, HL7v2.Type.ID, :o, 1},
      {15, :pharmacy_treatment_suppliers_special_dispensing_instructions, HL7v2.Type.CE, :o,
       :unbounded},
      {16, :actual_strength, HL7v2.Type.NM, :o, 1},
      {17, :actual_strength_unit, HL7v2.Type.CE, :o, 1},
      {18, :substance_lot_number, HL7v2.Type.ST, :o, :unbounded},
      {19, :substance_expiration_date, HL7v2.Type.TS, :o, :unbounded},
      {20, :substance_manufacturer_name, HL7v2.Type.CE, :o, :unbounded},
      {21, :indication, HL7v2.Type.CE, :o, :unbounded},
      {22, :dispense_package_size, HL7v2.Type.NM, :o, 1},
      {23, :dispense_package_size_unit, HL7v2.Type.CE, :o, 1},
      {24, :dispense_package_method, HL7v2.Type.ID, :o, 1},
      {25, :supplementary_code, HL7v2.Type.CE, :o, :unbounded},
      {26, :initiating_location, HL7v2.Type.CE, :o, 1},
      {27, :packaging_assembly_location, HL7v2.Type.CE, :o, 1},
      {28, :actual_drug_strength_volume, HL7v2.Type.NM, :o, 1},
      {29, :actual_drug_strength_volume_units, HL7v2.Type.CWE, :o, 1},
      {30, :dispense_to_pharmacy, HL7v2.Type.CWE, :o, 1},
      {31, :dispense_to_pharmacy_address, HL7v2.Type.XAD, :o, 1},
      {32, :pharmacy_order_type, HL7v2.Type.ID, :o, 1},
      {33, :dispense_type, HL7v2.Type.CWE, :o, 1}
    ]
end
