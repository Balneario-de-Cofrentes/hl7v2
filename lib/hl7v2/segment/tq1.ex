defmodule HL7v2.Segment.TQ1 do
  @moduledoc """
  Timing/Quantity (TQ1) segment — HL7v2 v2.5.1.

  Defines the timing and quantity for service requests. Replaces the
  legacy TQ data type with a dedicated segment for richer scheduling.

  14 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "TQ1",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :o, 1},
      {2, :quantity, HL7v2.Type.CQ, :o, 1},
      {3, :repeat_pattern, :raw, :o, :unbounded},
      {4, :explicit_time, HL7v2.Type.TM, :o, :unbounded},
      {5, :relative_time_and_units, HL7v2.Type.CQ, :o, :unbounded},
      {6, :service_duration, HL7v2.Type.CQ, :o, 1},
      {7, :start_date_time, HL7v2.Type.TS, :o, 1},
      {8, :end_date_time, HL7v2.Type.TS, :o, 1},
      {9, :priority, HL7v2.Type.CWE, :o, :unbounded},
      {10, :condition_text, HL7v2.Type.TX, :o, 1},
      {11, :text_instruction, HL7v2.Type.TX, :o, 1},
      {12, :conjunction, HL7v2.Type.ID, :o, 1},
      {13, :occurrence_duration, HL7v2.Type.CQ, :o, 1},
      {14, :total_occurrences, HL7v2.Type.NM, :o, 1}
    ]
end
