defmodule HL7v2.Segment.EQU do
  @moduledoc """
  Equipment Detail (EQU) segment — HL7v2 v2.5.1.

  Contains status information about a piece of equipment.

  5 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "EQU",
    fields: [
      {1, :equipment_instance_identifier, HL7v2.Type.EI, :r, 1},
      {2, :event_date_time, HL7v2.Type.TS, :r, 1},
      {3, :equipment_state, HL7v2.Type.CE, :o, 1},
      {4, :local_remote_control_state, HL7v2.Type.CE, :o, 1},
      {5, :alert_level, HL7v2.Type.CE, :o, 1}
    ]
end
