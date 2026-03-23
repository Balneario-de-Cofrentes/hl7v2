defmodule HL7v2.Segment.RXA do
  @moduledoc """
  Pharmacy/Treatment Administration (RXA) segment — HL7v2 v2.5.1.

  Records the actual administration of a medication or treatment to a patient.
  26 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "RXA",
    fields: [
      {1, :give_sub_id_counter, HL7v2.Type.NM, :r, 1},
      {2, :administration_sub_id_counter, HL7v2.Type.NM, :r, 1},
      {3, :date_time_start_of_administration, HL7v2.Type.TS, :r, 1},
      {4, :date_time_end_of_administration, HL7v2.Type.TS, :o, 1},
      {5, :administered_code, HL7v2.Type.CE, :r, 1},
      {6, :administered_amount, HL7v2.Type.NM, :r, 1},
      {7, :administered_units, HL7v2.Type.CE, :o, 1},
      {8, :administered_dosage_form, HL7v2.Type.CE, :o, 1},
      {9, :administration_notes, HL7v2.Type.CE, :o, :unbounded},
      {10, :administering_provider, HL7v2.Type.XCN, :o, :unbounded},
      {11, :administered_at_location, :raw, :o, 1},
      {12, :administered_per_time_unit, HL7v2.Type.ST, :o, 1},
      {13, :administered_strength, HL7v2.Type.NM, :o, 1},
      {14, :administered_strength_units, HL7v2.Type.CE, :o, 1},
      {15, :substance_lot_number, HL7v2.Type.ST, :o, :unbounded},
      {16, :substance_expiration_date, HL7v2.Type.TS, :o, :unbounded},
      {17, :substance_manufacturer_name, HL7v2.Type.CE, :o, :unbounded},
      {18, :substance_treatment_refusal_reason, HL7v2.Type.CE, :o, :unbounded},
      {19, :indication, HL7v2.Type.CE, :o, :unbounded},
      {20, :completion_status, HL7v2.Type.ID, :o, 1},
      {21, :action_code, HL7v2.Type.ID, :o, 1},
      {22, :system_entry_date_time, HL7v2.Type.TS, :o, 1},
      {23, :administered_drug_strength_volume, HL7v2.Type.NM, :o, 1},
      {24, :administered_drug_strength_volume_units, HL7v2.Type.CWE, :o, 1},
      {25, :administered_barcode_identifier, HL7v2.Type.CWE, :o, 1},
      {26, :pharmacy_order_type, HL7v2.Type.ID, :o, 1}
    ]
end
