defmodule HL7v2.Segment.NST do
  @moduledoc """
  Application Control Level Statistics (NST) segment -- HL7v2 v2.5.1.

  Contains application control level statistics.

  15 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "NST",
    fields: [
      {1, :statistics_available, HL7v2.Type.ID, :r, 1},
      {2, :source_identifier, HL7v2.Type.ST, :o, 1},
      {3, :source_type, HL7v2.Type.ID, :o, 1},
      {4, :statistics_start, HL7v2.Type.TS, :o, 1},
      {5, :statistics_end, HL7v2.Type.TS, :o, 1},
      {6, :receive_character_count, HL7v2.Type.NM, :o, 1},
      {7, :send_character_count, HL7v2.Type.NM, :o, 1},
      {8, :messages_received, HL7v2.Type.NM, :o, 1},
      {9, :messages_sent, HL7v2.Type.NM, :o, 1},
      {10, :checksum_errors_received, HL7v2.Type.NM, :o, 1},
      {11, :length_errors_received, HL7v2.Type.NM, :o, 1},
      {12, :other_errors_received, HL7v2.Type.NM, :o, 1},
      {13, :connect_timeouts, HL7v2.Type.NM, :o, 1},
      {14, :receive_timeouts, HL7v2.Type.NM, :o, 1},
      {15, :application_control_level_errors, HL7v2.Type.NM, :o, 1}
    ]
end
