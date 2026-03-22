defmodule HL7v2.Segment.EVN do
  @moduledoc """
  Event Type (EVN) segment — HL7v2 v2.5.1.

  Communicates trigger event information. 7 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "EVN",
    fields: [
      {1, :event_type_code, HL7v2.Type.ID, :b, 1},
      {2, :recorded_date_time, HL7v2.Type.TS, :r, 1},
      {3, :date_time_planned_event, HL7v2.Type.TS, :o, 1},
      {4, :event_reason_code, HL7v2.Type.IS, :o, 1},
      {5, :operator_id, HL7v2.Type.XCN, :o, :unbounded},
      {6, :event_occurred, HL7v2.Type.TS, :o, 1},
      {7, :event_facility, HL7v2.Type.HD, :o, 1}
    ]
end
