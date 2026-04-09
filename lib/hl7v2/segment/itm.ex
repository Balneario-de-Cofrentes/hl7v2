defmodule HL7v2.Segment.ITM do
  @moduledoc """
  Material Item Master (ITM) segment — HL7v2 v2.6+ (Chapter 17 Materials Management).

  Contains material item master information for supply chain management.
  Describes an item such as its identifier, description, category, manufacturer,
  regulatory approvals, and supply risk classification.

  18 fields per HL7 v2.6 specification.
  """

  use HL7v2.Segment,
    id: "ITM",
    fields: [
      {1, :item_identifier, HL7v2.Type.EI, :r, 1},
      {2, :item_description, HL7v2.Type.ST, :o, 1},
      {3, :item_status, HL7v2.Type.CWE, :o, 1},
      {4, :item_type, HL7v2.Type.CWE, :o, 1},
      {5, :item_category, HL7v2.Type.CWE, :o, 1},
      {6, :subject_to_expiration_indicator, HL7v2.Type.ID, :o, 1},
      {7, :manufacturer_identifier, HL7v2.Type.EI, :o, 1},
      {8, :manufacturer_name, HL7v2.Type.ST, :o, 1},
      {9, :manufacturer_catalog_number, HL7v2.Type.ST, :o, 1},
      {10, :manufacturer_labeler_identification_code, HL7v2.Type.CWE, :o, 1},
      {11, :patient_chargeable_indicator, HL7v2.Type.ID, :o, 1},
      {12, :transaction_code, HL7v2.Type.CWE, :o, 1},
      {13, :transaction_amount_unit, HL7v2.Type.CP, :o, 1},
      {14, :stocked_item_indicator, HL7v2.Type.ID, :o, 1},
      {15, :supply_risk_codes, HL7v2.Type.CWE, :o, 1},
      {16, :approving_regulatory_agency, HL7v2.Type.XON, :o, :unbounded},
      {17, :latex_indicator, HL7v2.Type.ID, :o, 1},
      {18, :ruling_act, HL7v2.Type.CWE, :o, :unbounded}
    ]
end
