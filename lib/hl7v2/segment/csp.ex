defmodule HL7v2.Segment.CSP do
  @moduledoc """
  Clinical Study Phase (CSP) segment — HL7v2 v2.5.1.

  Contains patient-specific clinical study phase information.

  4 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "CSP",
    fields: [
      {1, :study_phase_identifier, HL7v2.Type.CE, :r, 1},
      {2, :date_time_study_phase_began, HL7v2.Type.TS, :r, 1},
      {3, :date_time_study_phase_ended, HL7v2.Type.TS, :o, 1},
      {4, :study_phase_evaluability, HL7v2.Type.CE, :c, 1}
    ]
end
