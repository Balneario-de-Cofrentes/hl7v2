defmodule HL7v2.Segment.AUT do
  @moduledoc """
  Authorization Information (AUT) segment — HL7v2 v2.5.1.

  Defines authorization/pre-certification information for healthcare services.

  10 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "AUT",
    fields: [
      {1, :authorizing_payor_plan_id, HL7v2.Type.CE, :o, 1},
      {2, :authorizing_payor_company_id, HL7v2.Type.CE, :r, 1},
      {3, :authorizing_payor_company_name, HL7v2.Type.ST, :o, 1},
      {4, :authorization_effective_date, HL7v2.Type.TS, :o, 1},
      {5, :authorization_expiration_date, HL7v2.Type.TS, :o, 1},
      {6, :authorization_identifier, HL7v2.Type.EI, :o, 1},
      {7, :reimbursement_limit, HL7v2.Type.CP, :o, 1},
      {8, :requested_number_of_treatments, HL7v2.Type.NM, :o, 1},
      {9, :authorized_number_of_treatments, HL7v2.Type.NM, :o, 1},
      {10, :process_date, HL7v2.Type.TS, :o, 1}
    ]
end
