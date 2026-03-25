defmodule HL7v2.Segment.FTS do
  @moduledoc """
  File Trailer (FTS) segment — HL7v2 v2.5.1.

  Defines the end of a batch file.

  2 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "FTS",
    fields: [
      {1, :file_batch_count, HL7v2.Type.NM, :o, 1},
      {2, :file_trailer_comment, HL7v2.Type.ST, :o, 1}
    ]
end
