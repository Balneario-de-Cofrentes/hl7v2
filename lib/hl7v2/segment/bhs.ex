defmodule HL7v2.Segment.BHS do
  @moduledoc """
  Batch Header (BHS) segment — HL7v2 v2.5.1.

  Defines the start of a batch within a file, analogous to MSH for a message.

  12 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "BHS",
    fields: [
      {1, :batch_field_separator, HL7v2.Type.ST, :r, 1},
      {2, :batch_encoding_characters, HL7v2.Type.ST, :r, 1},
      {3, :batch_sending_application, HL7v2.Type.HD, :o, 1},
      {4, :batch_sending_facility, HL7v2.Type.HD, :o, 1},
      {5, :batch_receiving_application, HL7v2.Type.HD, :o, 1},
      {6, :batch_receiving_facility, HL7v2.Type.HD, :o, 1},
      {7, :batch_creation_date_time, HL7v2.Type.TS, :o, 1},
      {8, :batch_security, HL7v2.Type.ST, :o, 1},
      {9, :batch_name_type_id, HL7v2.Type.ST, :o, 1},
      {10, :batch_comment, HL7v2.Type.ST, :o, 1},
      {11, :batch_control_id, HL7v2.Type.ST, :o, 1},
      {12, :reference_batch_control_id, HL7v2.Type.ST, :o, 1}
    ]
end
