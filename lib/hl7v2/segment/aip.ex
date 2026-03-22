defmodule HL7v2.Segment.AIP do
  @moduledoc """
  Appointment Information — Personnel Resource (AIP) segment — HL7v2 v2.5.1.

  Contains personnel-specific scheduling information.
  12 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "AIP",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :r, 1},
      {2, :segment_action_code, HL7v2.Type.ID, :c, 1},
      {3, :personnel_resource_id, HL7v2.Type.XCN, :o, :unbounded},
      {4, :resource_type, HL7v2.Type.CE, :o, 1},
      {5, :resource_group, HL7v2.Type.CE, :o, 1},
      {6, :start_date_time, HL7v2.Type.TS, :o, 1},
      {7, :start_date_time_offset, HL7v2.Type.NM, :o, 1},
      {8, :start_date_time_offset_units, HL7v2.Type.CE, :o, 1},
      {9, :duration, HL7v2.Type.NM, :o, 1},
      {10, :duration_units, HL7v2.Type.CE, :o, 1},
      {11, :allow_substitution_code, HL7v2.Type.IS, :o, 1},
      {12, :filler_status_code, HL7v2.Type.CE, :o, 1}
    ]
end
