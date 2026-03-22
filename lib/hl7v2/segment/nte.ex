defmodule HL7v2.Segment.NTE do
  @moduledoc """
  Notes and Comments (NTE) segment — HL7v2 v2.5.1.

  Carries free-text notes and comments attached to other segments.
  4 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "NTE",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :o, 1},
      {2, :source_of_comment, HL7v2.Type.ID, :o, 1},
      {3, :comment, HL7v2.Type.FT, :o, :unbounded},
      {4, :comment_type, HL7v2.Type.CE, :o, 1}
    ]
end
