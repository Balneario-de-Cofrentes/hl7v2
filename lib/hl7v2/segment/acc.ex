defmodule HL7v2.Segment.ACC do
  @moduledoc """
  Accident (ACC) segment — HL7v2 v2.5.1.

  Contains accident-related information for a patient encounter.
  11 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "ACC",
    fields: [
      {1, :accident_date_time, HL7v2.Type.TS, :o, 1},
      {2, :accident_code, HL7v2.Type.CE, :o, 1},
      {3, :accident_location, HL7v2.Type.ST, :o, 1},
      {4, :auto_accident_state, HL7v2.Type.CE, :o, 1},
      {5, :accident_job_related_indicator, HL7v2.Type.ID, :o, 1},
      {6, :accident_death_indicator, HL7v2.Type.ID, :o, 1},
      {7, :entered_by, HL7v2.Type.XCN, :o, 1},
      {8, :accident_description, HL7v2.Type.ST, :o, 1},
      {9, :brought_in_by, HL7v2.Type.ST, :o, 1},
      {10, :police_notified_indicator, HL7v2.Type.ID, :o, 1},
      {11, :accident_address, HL7v2.Type.XAD, :o, 1}
    ]
end
