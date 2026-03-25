defmodule HL7v2.Segment.CNS do
  @moduledoc """
  Clear Notification (CNS) segment — HL7v2 v2.5.1.

  Used to clear pending notifications for automation instruments.

  6 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "CNS",
    fields: [
      {1, :starting_notification_reference_number, HL7v2.Type.NM, :o, 1},
      {2, :ending_notification_reference_number, HL7v2.Type.NM, :o, 1},
      {3, :starting_notification_date_time, HL7v2.Type.TS, :o, 1},
      {4, :ending_notification_date_time, HL7v2.Type.TS, :o, 1},
      {5, :starting_notification_code, HL7v2.Type.CE, :o, 1},
      {6, :ending_notification_code, HL7v2.Type.CE, :o, 1}
    ]
end
