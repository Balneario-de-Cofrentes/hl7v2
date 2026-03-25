defmodule HL7v2.Segment.AFF do
  @moduledoc """
  Professional Affiliation (AFF) segment -- HL7v2 v2.5.1.

  Contains professional affiliation information for staff members.

  5 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "AFF",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :r, 1},
      {2, :professional_organization, HL7v2.Type.XON, :r, 1},
      {3, :professional_organization_address, HL7v2.Type.XAD, :o, 1},
      {4, :professional_organization_affiliation_date_range, HL7v2.Type.DR, :o, :unbounded},
      {5, :professional_affiliation_additional_information, HL7v2.Type.ST, :o, 1}
    ]
end
