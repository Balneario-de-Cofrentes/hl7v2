defmodule HL7v2.Segment.RXO do
  @moduledoc """
  Pharmacy/Treatment Order (RXO) segment — HL7v2 v2.5.1.

  Contains the details of a pharmacy/treatment order request.
  25 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "RXO",
    fields: [
      {1, :requested_give_code, HL7v2.Type.CE, :r, 1},
      {2, :requested_give_amount_minimum, HL7v2.Type.NM, :o, 1},
      {3, :requested_give_amount_maximum, HL7v2.Type.NM, :o, 1},
      {4, :requested_give_units, HL7v2.Type.CE, :r, 1},
      {5, :requested_dosage_form, HL7v2.Type.CE, :o, 1},
      {6, :providers_pharmacy_treatment_instructions, HL7v2.Type.CE, :o, :unbounded},
      {7, :providers_administration_instructions, HL7v2.Type.CE, :o, :unbounded},
      {8, :deliver_to_location, :raw, :o, 1},
      {9, :allow_substitutions, HL7v2.Type.ID, :o, 1},
      {10, :requested_dispense_code, HL7v2.Type.CE, :o, 1},
      {11, :requested_dispense_amount, HL7v2.Type.NM, :o, 1},
      {12, :requested_dispense_units, HL7v2.Type.CE, :o, 1},
      {13, :number_of_refills, HL7v2.Type.NM, :o, 1},
      {14, :ordering_providers_dea_number, HL7v2.Type.XCN, :o, :unbounded},
      {15, :pharmacist_treatment_suppliers_verifier_id, HL7v2.Type.XCN, :o, :unbounded},
      {16, :needs_human_review, HL7v2.Type.ID, :o, 1},
      {17, :requested_give_per_time_unit, HL7v2.Type.ST, :o, 1},
      {18, :requested_give_strength, HL7v2.Type.NM, :o, 1},
      {19, :requested_give_strength_units, HL7v2.Type.CE, :o, 1},
      {20, :indication, HL7v2.Type.CE, :o, :unbounded},
      {21, :requested_give_rate_amount, HL7v2.Type.ST, :o, 1},
      {22, :requested_give_rate_units, HL7v2.Type.CE, :o, 1},
      {23, :total_daily_dose, HL7v2.Type.CQ, :o, 1},
      {24, :supplementary_code, HL7v2.Type.CE, :o, :unbounded},
      {25, :requested_drug_strength_volume, HL7v2.Type.NM, :o, 1}
    ]
end
