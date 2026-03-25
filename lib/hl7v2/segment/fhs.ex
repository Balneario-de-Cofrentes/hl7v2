defmodule HL7v2.Segment.FHS do
  @moduledoc """
  File Header (FHS) segment — HL7v2 v2.5.1.

  Defines the start of a batch file, analogous to MSH for a single message.

  12 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "FHS",
    fields: [
      {1, :file_field_separator, HL7v2.Type.ST, :r, 1},
      {2, :file_encoding_characters, HL7v2.Type.ST, :r, 1},
      {3, :file_sending_application, HL7v2.Type.HD, :o, 1},
      {4, :file_sending_facility, HL7v2.Type.HD, :o, 1},
      {5, :file_receiving_application, HL7v2.Type.HD, :o, 1},
      {6, :file_receiving_facility, HL7v2.Type.HD, :o, 1},
      {7, :file_creation_date_time, HL7v2.Type.TS, :o, 1},
      {8, :file_security, HL7v2.Type.ST, :o, 1},
      {9, :file_name_id, HL7v2.Type.ST, :o, 1},
      {10, :file_header_comment, HL7v2.Type.ST, :o, 1},
      {11, :file_control_id, HL7v2.Type.ST, :o, 1},
      {12, :reference_file_control_id, HL7v2.Type.ST, :o, 1}
    ]
end
