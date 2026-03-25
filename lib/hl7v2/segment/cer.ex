defmodule HL7v2.Segment.CER do
  @moduledoc """
  Certificate Detail (CER) segment — HL7v2 v2.5.1.

  Contains certificate information for personnel or organizations.
  First 20 fields are typed; remaining fields use `:raw` for lossless round-trip.

  31 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "CER",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :r, 1},
      {2, :serial_number, HL7v2.Type.ST, :o, 1},
      {3, :version, HL7v2.Type.ST, :o, 1},
      {4, :granting_authority, HL7v2.Type.XON, :o, 1},
      {5, :issuing_authority, HL7v2.Type.XCN, :o, 1},
      {6, :signature_of_issuing_authority, HL7v2.Type.ED, :o, 1},
      {7, :granting_country, HL7v2.Type.ID, :o, 1},
      {8, :granting_state_province, HL7v2.Type.CWE, :o, 1},
      {9, :granting_county_parish, HL7v2.Type.CWE, :o, 1},
      {10, :certificate_type, HL7v2.Type.CWE, :o, 1},
      {11, :certificate_domain, HL7v2.Type.CWE, :o, 1},
      {12, :subject_id, HL7v2.Type.EI, :o, 1},
      {13, :subject_name, HL7v2.Type.ST, :r, 1},
      {14, :subject_directory_attribute_extension, HL7v2.Type.CWE, :o, :unbounded},
      {15, :subject_public_key_info, HL7v2.Type.CWE, :o, 1},
      {16, :authority_key_identifier, HL7v2.Type.CWE, :o, 1},
      {17, :basic_constraint, HL7v2.Type.ID, :o, 1},
      {18, :crl_distribution_point, HL7v2.Type.CWE, :o, :unbounded},
      {19, :jurisdiction_country, HL7v2.Type.ID, :o, 1},
      {20, :jurisdiction_state_province, HL7v2.Type.CWE, :o, 1},
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
      {31, :field_31, :raw, :o, 1}
    ]
end
