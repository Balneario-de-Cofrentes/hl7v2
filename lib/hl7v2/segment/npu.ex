defmodule HL7v2.Segment.NPU do
  @moduledoc """
  Bed Status Update (NPU) segment — HL7v2 v2.5.1.

  Used to communicate changes to bed/room status.

  2 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "NPU",
    fields: [
      {1, :bed_location, HL7v2.Type.PL, :r, 1},
      {2, :bed_status, HL7v2.Type.IS, :o, 1}
    ]
end
