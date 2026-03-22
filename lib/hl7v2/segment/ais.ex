defmodule HL7v2.Segment.AIS do
  @moduledoc """
  Appointment Information — Service (AIS) segment — HL7v2 v2.5.1.

  Contains service-specific scheduling information.
  12 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "AIS",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :r, 1},
      {2, :segment_action_code, HL7v2.Type.ID, :c, 1},
      {3, :universal_service_identifier, HL7v2.Type.CE, :r, 1},
      {4, :start_date_time, HL7v2.Type.TS, :o, 1},
      {5, :start_date_time_offset, HL7v2.Type.NM, :o, 1},
      {6, :start_date_time_offset_units, HL7v2.Type.CE, :o, 1},
      {7, :duration, HL7v2.Type.NM, :o, 1},
      {8, :duration_units, HL7v2.Type.CE, :o, 1},
      {9, :allow_substitution_code, HL7v2.Type.IS, :o, 1},
      {10, :filler_status_code, HL7v2.Type.CE, :o, 1},
      {11, :placer_supplemental_service_information, HL7v2.Type.CE, :o, :unbounded},
      {12, :filler_supplemental_service_information, HL7v2.Type.CE, :o, :unbounded}
    ]
end
