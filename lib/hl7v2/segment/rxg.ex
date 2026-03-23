defmodule HL7v2.Segment.RXG do
  @moduledoc """
  Pharmacy/Treatment Give (RXG) segment — HL7v2 v2.5.1.

  Contains information about a single give event for a medication or treatment.
  27 fields per HL7 v2.5.1 specification; fields 1-10 and select later fields
  typed, remainder raw for lossless round-trip.
  """

  use HL7v2.Segment,
    id: "RXG",
    fields: [
      {1, :give_sub_id_counter, HL7v2.Type.NM, :r, 1},
      {2, :dispense_sub_id_counter, HL7v2.Type.NM, :o, 1},
      {3, :quantity_timing, HL7v2.Type.TQ, :o, 1},
      {4, :give_code, HL7v2.Type.CE, :r, 1},
      {5, :give_amount_minimum, HL7v2.Type.NM, :r, 1},
      {6, :give_amount_maximum, HL7v2.Type.NM, :o, 1},
      {7, :give_units, HL7v2.Type.CE, :r, 1},
      {8, :give_dosage_form, HL7v2.Type.CE, :o, 1},
      {9, :administration_notes, HL7v2.Type.CE, :o, :unbounded},
      {10, :substitution_status, HL7v2.Type.ID, :o, 1},
      {11, :dispense_to_location, :raw, :o, 1},
      {12, :needs_human_review, HL7v2.Type.ID, :o, 1},
      {13, :pharmacy_treatment_suppliers_special_dispensing_instructions, HL7v2.Type.CE, :o,
       :unbounded},
      {14, :give_per_time_unit, HL7v2.Type.ST, :o, 1},
      {15, :give_strength, HL7v2.Type.NM, :o, 1},
      {16, :give_strength_units, HL7v2.Type.CE, :o, 1},
      {17, :substance_lot_number, HL7v2.Type.ST, :o, :unbounded},
      {18, :substance_expiration_date, HL7v2.Type.TS, :o, :unbounded},
      {19, :substance_manufacturer_name, HL7v2.Type.CE, :o, :unbounded},
      {20, :indication, HL7v2.Type.CE, :o, :unbounded},
      {21, :give_drug_strength_volume, HL7v2.Type.NM, :o, 1},
      {22, :give_drug_strength_volume_units, HL7v2.Type.CWE, :o, 1},
      {23, :give_barcode_identifier, HL7v2.Type.CWE, :o, 1},
      {24, :pharmacy_order_type, HL7v2.Type.ID, :o, 1},
      {25, :field_25, :raw, :o, 1},
      {26, :field_26, :raw, :o, 1},
      {27, :field_27, :raw, :o, 1}
    ]
end
