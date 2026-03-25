defmodule HL7v2.Segment.CTD do
  @moduledoc """
  Contact Data (CTD) segment — HL7v2 v2.5.1.

  Identifies contact personnel and their roles, addresses, and
  communication information. Used in referral and other messages.

  7 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "CTD",
    fields: [
      {1, :contact_role, HL7v2.Type.CE, :r, :unbounded},
      {2, :contact_name, HL7v2.Type.XPN, :o, :unbounded},
      {3, :contact_address, HL7v2.Type.XAD, :o, :unbounded},
      {4, :contact_location, HL7v2.Type.PL, :o, 1},
      {5, :contact_communication_information, HL7v2.Type.XTN, :o, :unbounded},
      {6, :preferred_method_of_contact, HL7v2.Type.CE, :o, 1},
      {7, :contact_identifiers, HL7v2.Type.PLN, :o, :unbounded}
    ]
end
