defmodule HL7v2.Segment.PRD do
  @moduledoc """
  Provider Data (PRD) segment -- HL7v2 v2.5.1.

  Contains provider data for referrals and other messages.
  9 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "PRD",
    fields: [
      {1, :provider_role, HL7v2.Type.CE, :r, :unbounded},
      {2, :provider_name, HL7v2.Type.XPN, :o, :unbounded},
      {3, :provider_address, HL7v2.Type.XAD, :o, 1},
      {4, :provider_location, HL7v2.Type.PL, :o, 1},
      {5, :provider_communication_information, HL7v2.Type.XTN, :o, :unbounded},
      {6, :preferred_method_of_contact, HL7v2.Type.CE, :o, 1},
      {7, :provider_identifiers, :raw, :o, :unbounded},
      {8, :effective_start_date_of_provider_role, HL7v2.Type.TS, :o, 1},
      {9, :effective_end_date_of_provider_role, HL7v2.Type.TS, :o, :unbounded}
    ]
end
