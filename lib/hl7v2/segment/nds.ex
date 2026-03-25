defmodule HL7v2.Segment.NDS do
  @moduledoc """
  Notification Detail (NDS) segment -- HL7v2 v2.5.1.

  Contains notification detail information for system events.

  4 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "NDS",
    fields: [
      {1, :notification_reference_number, HL7v2.Type.NM, :r, 1},
      {2, :notification_date_time, HL7v2.Type.TS, :r, 1},
      {3, :notification_alert_severity, HL7v2.Type.NM, :r, 1},
      {4, :notification_code, HL7v2.Type.CE, :r, 1}
    ]
end
