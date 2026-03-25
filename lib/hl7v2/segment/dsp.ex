defmodule HL7v2.Segment.DSP do
  @moduledoc """
  Display Data (DSP) segment — HL7v2 v2.5.1.

  Used to send formatted text for display purposes.

  5 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "DSP",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :o, 1},
      {2, :display_level, HL7v2.Type.SI, :o, 1},
      {3, :data_line, HL7v2.Type.TX, :r, 1},
      {4, :logical_break_point, HL7v2.Type.ST, :o, 1},
      {5, :result_id, HL7v2.Type.TX, :o, 1}
    ]
end
