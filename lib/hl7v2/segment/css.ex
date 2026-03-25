defmodule HL7v2.Segment.CSS do
  @moduledoc """
  Clinical Study Data Schedule (CSS) segment — HL7v2 v2.5.1.

  Contains data schedule information for a clinical study time point.

  3 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "CSS",
    fields: [
      {1, :study_scheduled_time_point, HL7v2.Type.CE, :r, 1},
      {2, :study_scheduled_patient_time_point, HL7v2.Type.TS, :o, 1},
      {3, :study_quality_control_codes, HL7v2.Type.CE, :o, :unbounded}
    ]
end
