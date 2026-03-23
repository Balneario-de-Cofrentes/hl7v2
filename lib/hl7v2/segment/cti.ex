defmodule HL7v2.Segment.CTI do
  @moduledoc """
  Clinical Trial Identification (CTI) segment — HL7v2 v2.5.1.

  Identifies the clinical trial, study phase, and scheduled time point
  associated with a patient or order.

  3 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "CTI",
    fields: [
      {1, :sponsor_study_id, HL7v2.Type.EI, :r, 1},
      {2, :study_phase_identifier, HL7v2.Type.CE, :o, 1},
      {3, :study_scheduled_time_point, HL7v2.Type.CE, :o, 1}
    ]
end
