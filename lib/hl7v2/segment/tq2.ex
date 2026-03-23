defmodule HL7v2.Segment.TQ2 do
  @moduledoc """
  Timing/Quantity Relationship (TQ2) segment — HL7v2 v2.5.1.

  Defines relationships between TQ1 segments, enabling complex
  sequencing, cycling, and conditional execution of service requests.

  10 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "TQ2",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :o, 1},
      {2, :sequence_results_flag, HL7v2.Type.ID, :o, 1},
      {3, :related_placer_number, HL7v2.Type.EI, :o, :unbounded},
      {4, :related_filler_number, HL7v2.Type.EI, :o, :unbounded},
      {5, :related_placer_group_number, HL7v2.Type.EI, :o, :unbounded},
      {6, :sequence_condition_code, HL7v2.Type.ID, :o, 1},
      {7, :cyclic_entry_exit_indicator, HL7v2.Type.ID, :o, 1},
      {8, :sequence_condition_time_interval, HL7v2.Type.CQ, :o, 1},
      {9, :cyclic_group_maximum_number_of_repeats, HL7v2.Type.NM, :o, 1},
      {10, :special_service_request_relationship, HL7v2.Type.ID, :o, 1}
    ]
end
