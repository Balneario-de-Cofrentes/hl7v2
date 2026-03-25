defmodule HL7v2.Segment.ERQ do
  @moduledoc """
  Event Replay Query (ERQ) segment -- HL7v2 v2.5.1.

  Withdrawn/deprecated query segment from v2.3 that still appears in the
  v2.5.1 index. Requests replay of events.

  3 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "ERQ",
    fields: [
      {1, :query_tag, HL7v2.Type.ST, :o, 1},
      {2, :event_identifier, HL7v2.Type.CE, :r, 1},
      {3, :input_parameter_list, :raw, :o, :unbounded}
    ]
end
