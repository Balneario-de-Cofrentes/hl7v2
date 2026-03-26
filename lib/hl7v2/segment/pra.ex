defmodule HL7v2.Segment.PRA do
  @moduledoc """
  Practitioner Detail (PRA) segment -- HL7v2 v2.5.1.

  Contains practitioner detail information.
  12 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "PRA",
    fields: [
      {1, :primary_key_value, HL7v2.Type.CE, :c, 1},
      {2, :practitioner_group, HL7v2.Type.CE, :o, :unbounded},
      {3, :practitioner_category, HL7v2.Type.IS, :o, :unbounded},
      {4, :provider_billing, HL7v2.Type.ID, :o, 1},
      {5, :specialty, HL7v2.Type.SPD, :o, :unbounded},
      {6, :practitioner_id_numbers, HL7v2.Type.PLN, :o, :unbounded},
      {7, :privileges, HL7v2.Type.PIP, :o, :unbounded},
      {8, :date_entered_practice, HL7v2.Type.DT, :o, 1},
      {9, :institution, HL7v2.Type.CE, :o, 1},
      {10, :date_left_practice, HL7v2.Type.DT, :o, 1},
      {11, :government_reimbursement_billing_eligibility, HL7v2.Type.CE, :o, :unbounded},
      {12, :set_id, HL7v2.Type.SI, :c, 1}
    ]
end
