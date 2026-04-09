defmodule HL7v2.Segment.VND do
  @moduledoc """
  Purchasing Vendor (VND) segment — HL7v2 v2.6+ (Chapter 17 Materials Management).

  Vendor master data: identifier, name, contact, and regulatory
  information for a purchasing vendor supplying material items.

  10 fields per HL7 v2.6 specification.
  """

  use HL7v2.Segment,
    id: "VND",
    fields: [
      {1, :set_id, HL7v2.Type.EI, :r, 1},
      {2, :vendor_identifier, HL7v2.Type.EI, :r, 1},
      {3, :vendor_name, HL7v2.Type.ST, :o, 1},
      {4, :vendor_catalog_number, HL7v2.Type.ST, :o, 1},
      {5, :primary_vendor_indicator, HL7v2.Type.CWE, :o, 1},
      {6, :corporation, HL7v2.Type.XON, :o, :unbounded},
      {7, :primary_contact, HL7v2.Type.XCN, :o, 1},
      {8, :contract_agreement, HL7v2.Type.CX, :o, 1},
      {9, :approving_regulatory_agency, HL7v2.Type.XON, :o, :unbounded},
      {10, :highest_level_of_concern_code, HL7v2.Type.CWE, :o, 1}
    ]
end
