defmodule HL7v2.Segment.URS do
  @moduledoc """
  Unsolicited Selection (URS) segment -- HL7v2 v2.5.1.

  Contains unsolicited selection criteria.
  8 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "URS",
    fields: [
      {1, :r_u_where_subject_definition, HL7v2.Type.ST, :r, :unbounded},
      {2, :r_u_when_data_start_date_time, HL7v2.Type.TS, :o, 1},
      {3, :r_u_when_data_end_date_time, HL7v2.Type.TS, :o, 1},
      {4, :r_u_what_user_qualifier, HL7v2.Type.ST, :o, :unbounded},
      {5, :r_u_other_results_subject_definition, HL7v2.Type.ST, :o, :unbounded},
      {6, :r_u_which_date_time_qualifier, HL7v2.Type.ID, :o, :unbounded},
      {7, :r_u_which_date_time_status_qualifier, HL7v2.Type.ID, :o, :unbounded},
      {8, :r_u_date_time_selection_qualifier, HL7v2.Type.ID, :o, :unbounded}
    ]
end
