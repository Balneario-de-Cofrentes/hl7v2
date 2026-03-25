defmodule HL7v2.Segment.ECR do
  @moduledoc """
  Equipment Command Response (ECR) segment — HL7v2 v2.5.1.

  Contains the response to an equipment command.

  3 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "ECR",
    fields: [
      {1, :command_response, HL7v2.Type.CE, :r, 1},
      {2, :date_time_completed, HL7v2.Type.TS, :r, 1},
      {3, :command_response_parameters, HL7v2.Type.ST, :o, :unbounded}
    ]
end
