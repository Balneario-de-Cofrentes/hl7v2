defmodule HL7v2.Segment.EDU do
  @moduledoc """
  Educational Detail (EDU) segment — HL7v2 v2.5.1.

  Contains educational background information for personnel.

  9 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "EDU",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :r, 1},
      {2, :academic_degree, HL7v2.Type.IS, :o, 1},
      {3, :academic_degree_program_date_range, HL7v2.Type.DR, :o, 1},
      {4, :academic_degree_program_participation_date_range, HL7v2.Type.DR, :o, 1},
      {5, :academic_degree_granted_date, HL7v2.Type.DT, :o, 1},
      {6, :school, HL7v2.Type.XON, :o, 1},
      {7, :school_type_code, HL7v2.Type.CE, :o, 1},
      {8, :school_address, HL7v2.Type.XAD, :o, 1},
      {9, :major_field_of_study, HL7v2.Type.CWE, :o, :unbounded}
    ]
end
