defmodule HL7v2.Segment.RF1 do
  @moduledoc """
  Referral Information (RF1) segment -- HL7v2 v2.5.1.

  Contains referral information.
  11 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "RF1",
    fields: [
      {1, :referral_status, HL7v2.Type.CE, :o, 1},
      {2, :referral_priority, HL7v2.Type.CE, :o, 1},
      {3, :referral_type, HL7v2.Type.CE, :o, 1},
      {4, :referral_disposition, HL7v2.Type.CE, :o, :unbounded},
      {5, :referral_category, HL7v2.Type.CE, :o, 1},
      {6, :originating_referral_identifier, HL7v2.Type.EI, :r, 1},
      {7, :effective_date, HL7v2.Type.TS, :o, 1},
      {8, :expiration_date, HL7v2.Type.TS, :o, 1},
      {9, :process_date, HL7v2.Type.TS, :o, 1},
      {10, :referral_reason, HL7v2.Type.CE, :o, :unbounded},
      {11, :external_referral_identifier, HL7v2.Type.EI, :o, :unbounded}
    ]
end
