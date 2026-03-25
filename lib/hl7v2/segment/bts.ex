defmodule HL7v2.Segment.BTS do
  @moduledoc """
  Batch Trailer (BTS) segment — HL7v2 v2.5.1.

  Defines the end of a batch within a file.

  3 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "BTS",
    fields: [
      {1, :batch_message_count, HL7v2.Type.ST, :o, 1},
      {2, :batch_comment, HL7v2.Type.ST, :o, 1},
      {3, :batch_totals, :raw, :o, 1}
    ]
end
