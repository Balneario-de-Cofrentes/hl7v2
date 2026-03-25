defmodule HL7v2.Segment.FAC do
  @moduledoc """
  Facility (FAC) segment — HL7v2 v2.5.1.

  Contains facility identification and contact information.

  12 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "FAC",
    fields: [
      {1, :facility_id, HL7v2.Type.EI, :r, 1},
      {2, :facility_type, HL7v2.Type.ID, :o, 1},
      {3, :facility_address, HL7v2.Type.XAD, :r, :unbounded},
      {4, :facility_telecommunication, HL7v2.Type.XTN, :r, 1},
      {5, :contact_person, HL7v2.Type.XCN, :o, :unbounded},
      {6, :contact_title, HL7v2.Type.ST, :o, :unbounded},
      {7, :contact_address, HL7v2.Type.XAD, :o, :unbounded},
      {8, :contact_telecommunication, HL7v2.Type.XTN, :o, :unbounded},
      {9, :signature_authority, HL7v2.Type.XCN, :r, :unbounded},
      {10, :signature_authority_title, HL7v2.Type.ST, :o, 1},
      {11, :signature_authority_address, HL7v2.Type.XAD, :o, :unbounded},
      {12, :signature_authority_telecommunication, HL7v2.Type.XTN, :r, 1}
    ]
end
