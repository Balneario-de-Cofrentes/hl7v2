defmodule HL7v2.Segment.DB1 do
  @moduledoc """
  Disability (DB1) segment — HL7v2 v2.5.1.

  Contains disability information for a patient.
  8 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "DB1",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :r, 1},
      {2, :disabled_person_code, HL7v2.Type.IS, :o, 1},
      {3, :disabled_person_identifier, HL7v2.Type.CX, :o, :unbounded},
      {4, :disabled_indicator, HL7v2.Type.ID, :o, 1},
      {5, :disability_start_date, HL7v2.Type.DT, :o, 1},
      {6, :disability_end_date, HL7v2.Type.DT, :o, 1},
      {7, :disability_return_to_work_date, HL7v2.Type.DT, :o, 1},
      {8, :disability_unable_to_work_date, HL7v2.Type.DT, :o, 1}
    ]
end
