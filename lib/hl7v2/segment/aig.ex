defmodule HL7v2.Segment.AIG do
  @moduledoc """
  Appointment Information — General Resource (AIG) segment — HL7v2 v2.5.1.

  Contains general resource scheduling information.
  14 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "AIG",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :r, 1},
      {2, :segment_action_code, HL7v2.Type.ID, :c, 1},
      {3, :resource_id, HL7v2.Type.CE, :o, 1},
      {4, :resource_type, HL7v2.Type.CE, :r, 1},
      {5, :resource_group, HL7v2.Type.CE, :o, :unbounded},
      {6, :resource_quantity, HL7v2.Type.NM, :o, 1},
      {7, :resource_quantity_units, HL7v2.Type.CE, :o, 1},
      {8, :start_date_time, HL7v2.Type.TS, :o, 1},
      {9, :start_date_time_offset, HL7v2.Type.NM, :o, 1},
      {10, :start_date_time_offset_units, HL7v2.Type.CE, :o, 1},
      {11, :duration, HL7v2.Type.NM, :o, 1},
      {12, :duration_units, HL7v2.Type.CE, :o, 1},
      {13, :allow_substitution_code, HL7v2.Type.IS, :o, 1},
      {14, :filler_status_code, HL7v2.Type.CE, :o, 1}
    ]
end
