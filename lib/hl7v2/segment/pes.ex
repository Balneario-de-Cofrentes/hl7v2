defmodule HL7v2.Segment.PES do
  @moduledoc """
  Product Experience Sender (PES) segment -- HL7v2 v2.5.1.

  Contains product experience sender information.
  13 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "PES",
    fields: [
      {1, :sender_organization_name, HL7v2.Type.XON, :o, :unbounded},
      {2, :sender_individual_name, HL7v2.Type.XCN, :o, :unbounded},
      {3, :sender_address, HL7v2.Type.XAD, :o, :unbounded},
      {4, :sender_telephone, HL7v2.Type.XTN, :o, :unbounded},
      {5, :sender_event_identifier, HL7v2.Type.EI, :o, 1},
      {6, :sender_sequence_number, HL7v2.Type.NM, :o, 1},
      {7, :sender_event_description, HL7v2.Type.FT, :o, :unbounded},
      {8, :sender_comment, HL7v2.Type.FT, :o, 1},
      {9, :sender_aware_date_time, HL7v2.Type.TS, :o, 1},
      {10, :event_report_date, HL7v2.Type.TS, :r, 1},
      {11, :event_report_timing_type, HL7v2.Type.ID, :o, :unbounded},
      {12, :event_report_source, HL7v2.Type.ID, :o, 1},
      {13, :event_reported_to, HL7v2.Type.ID, :o, :unbounded}
    ]
end
