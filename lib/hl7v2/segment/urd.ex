defmodule HL7v2.Segment.URD do
  @moduledoc """
  Results/Update Definition (URD) segment -- HL7v2 v2.5.1.

  Contains results/update definition information.
  7 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "URD",
    fields: [
      {1, :r_u_date_time, HL7v2.Type.TS, :o, 1},
      {2, :report_priority, HL7v2.Type.ID, :o, 1},
      {3, :r_u_who_subject_definition, HL7v2.Type.XCN, :r, :unbounded},
      {4, :r_u_what_subject_definition, HL7v2.Type.CE, :o, :unbounded},
      {5, :r_u_what_department_code, HL7v2.Type.CE, :o, :unbounded},
      {6, :r_u_display_print_locations, HL7v2.Type.ST, :o, :unbounded},
      {7, :r_u_results_level, HL7v2.Type.ID, :o, 1}
    ]
end
