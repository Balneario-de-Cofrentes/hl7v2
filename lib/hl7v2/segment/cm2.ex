defmodule HL7v2.Segment.CM2 do
  @moduledoc """
  Clinical Study Schedule Master (CM2) segment — HL7v2 v2.5.1.

  Contains schedule and time-point information for a clinical study.

  4 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "CM2",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :o, 1},
      {2, :scheduled_time_point, HL7v2.Type.CE, :r, 1},
      {3, :description_of_time_point, HL7v2.Type.ST, :o, 1},
      {4, :number_of_sample_containers, HL7v2.Type.NM, :r, 1}
    ]
end
