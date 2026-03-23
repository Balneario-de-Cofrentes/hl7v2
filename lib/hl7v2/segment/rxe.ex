defmodule HL7v2.Segment.RXE do
  @moduledoc """
  Pharmacy/Treatment Encoded Order (RXE) segment — HL7v2 v2.5.1.

  Contains the encoded (machine-processable) form of a pharmacy/treatment order.
  44 fields per HL7 v2.5.1 specification; fields 1-31 typed, 32-44 raw.
  """

  use HL7v2.Segment,
    id: "RXE",
    fields: [
      {1, :quantity_timing, HL7v2.Type.TQ, :o, 1},
      {2, :give_code, HL7v2.Type.CE, :r, 1},
      {3, :give_amount_minimum, HL7v2.Type.NM, :r, 1},
      {4, :give_amount_maximum, HL7v2.Type.NM, :o, 1},
      {5, :give_units, HL7v2.Type.CE, :r, 1},
      {6, :give_dosage_form, HL7v2.Type.CE, :o, 1},
      {7, :providers_administration_instructions, HL7v2.Type.CE, :o, :unbounded},
      {8, :deliver_to_location, :raw, :o, 1},
      {9, :substitution_status, HL7v2.Type.ID, :o, 1},
      {10, :dispense_amount, HL7v2.Type.NM, :o, 1},
      {11, :dispense_units, HL7v2.Type.CE, :o, 1},
      {12, :number_of_refills, HL7v2.Type.NM, :o, 1},
      {13, :ordering_providers_dea_number, HL7v2.Type.XCN, :o, :unbounded},
      {14, :pharmacist_treatment_suppliers_verifier_id, HL7v2.Type.XCN, :o, :unbounded},
      {15, :prescription_number, HL7v2.Type.ST, :o, 1},
      {16, :number_of_refills_remaining, HL7v2.Type.NM, :o, 1},
      {17, :number_of_refills_doses_dispensed, HL7v2.Type.NM, :o, 1},
      {18, :dt_of_most_recent_refill, HL7v2.Type.TS, :o, 1},
      {19, :total_daily_dose, HL7v2.Type.CQ, :o, 1},
      {20, :needs_human_review, HL7v2.Type.ID, :o, 1},
      {21, :pharmacy_treatment_suppliers_special_dispensing_instructions, HL7v2.Type.CE, :o,
       :unbounded},
      {22, :give_per_time_unit, HL7v2.Type.ST, :o, 1},
      {23, :give_rate_amount, HL7v2.Type.ST, :o, 1},
      {24, :give_rate_units, HL7v2.Type.CE, :o, 1},
      {25, :give_strength, HL7v2.Type.NM, :o, 1},
      {26, :give_strength_units, HL7v2.Type.CE, :o, 1},
      {27, :give_indication, HL7v2.Type.CE, :o, :unbounded},
      {28, :dispense_package_size, HL7v2.Type.NM, :o, 1},
      {29, :dispense_package_size_unit, HL7v2.Type.CE, :o, 1},
      {30, :dispense_package_method, HL7v2.Type.ID, :o, 1},
      {31, :supplementary_code, HL7v2.Type.CE, :o, :unbounded},
      {32, :field_32, :raw, :o, 1},
      {33, :field_33, :raw, :o, 1},
      {34, :field_34, :raw, :o, 1},
      {35, :field_35, :raw, :o, 1},
      {36, :field_36, :raw, :o, 1},
      {37, :field_37, :raw, :o, 1},
      {38, :field_38, :raw, :o, 1},
      {39, :field_39, :raw, :o, 1},
      {40, :field_40, :raw, :o, 1},
      {41, :field_41, :raw, :o, 1},
      {42, :field_42, :raw, :o, 1},
      {43, :field_43, :raw, :o, 1},
      {44, :field_44, :raw, :o, 1}
    ]
end
