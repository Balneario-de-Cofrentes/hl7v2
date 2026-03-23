defmodule HL7v2.Segment.DSC do
  @moduledoc """
  Continuation Pointer (DSC) segment — HL7v2 v2.5.1.

  Used to indicate that a response is continued in a subsequent message,
  providing a continuation pointer and style.

  2 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "DSC",
    fields: [
      {1, :continuation_pointer, HL7v2.Type.ST, :o, 1},
      {2, :continuation_style, HL7v2.Type.ID, :o, 1}
    ]
end
