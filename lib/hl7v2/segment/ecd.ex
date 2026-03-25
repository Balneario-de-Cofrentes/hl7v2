defmodule HL7v2.Segment.ECD do
  @moduledoc """
  Equipment Command (ECD) segment — HL7v2 v2.5.1.

  Contains commands sent to equipment for automation/instrument control.

  5 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "ECD",
    fields: [
      {1, :reference_command_number, HL7v2.Type.NM, :r, 1},
      {2, :remote_control_command, HL7v2.Type.CE, :r, 1},
      {3, :response_required, HL7v2.Type.ID, :o, 1},
      {4, :requested_completion_time, HL7v2.Type.TQ, :o, 1},
      {5, :parameters, HL7v2.Type.CE, :o, :unbounded}
    ]
end
