defmodule HL7v2.Segment.PRB do
  @moduledoc """
  Problem Details (PRB) segment -- HL7v2 v2.5.1.

  Contains problem detail information.
  25 fields per HL7 v2.5.1 specification. Fields 1-15 are typed,
  fields 16-25 use :raw.
  """

  use HL7v2.Segment,
    id: "PRB",
    fields: [
      {1, :action_code, HL7v2.Type.ID, :r, 1},
      {2, :action_date_time, HL7v2.Type.TS, :r, 1},
      {3, :problem_id, HL7v2.Type.CE, :r, 1},
      {4, :problem_instance_id, HL7v2.Type.EI, :r, 1},
      {5, :episode_of_care_id, HL7v2.Type.EI, :o, 1},
      {6, :problem_list_priority, HL7v2.Type.NM, :o, 1},
      {7, :problem_established_date_time, HL7v2.Type.TS, :o, 1},
      {8, :anticipated_problem_resolution_date_time, HL7v2.Type.TS, :o, 1},
      {9, :actual_problem_resolution_date_time, HL7v2.Type.TS, :o, 1},
      {10, :problem_classification, HL7v2.Type.CE, :o, 1},
      {11, :problem_management_discipline, HL7v2.Type.CE, :o, :unbounded},
      {12, :problem_persistence, HL7v2.Type.CE, :o, 1},
      {13, :problem_confirmation_status, HL7v2.Type.CE, :o, 1},
      {14, :problem_life_cycle_status, HL7v2.Type.CE, :o, 1},
      {15, :problem_life_cycle_status_date_time, HL7v2.Type.TS, :o, 1},
      {16, :field_16, :raw, :o, 1},
      {17, :field_17, :raw, :o, 1},
      {18, :field_18, :raw, :o, 1},
      {19, :field_19, :raw, :o, 1},
      {20, :field_20, :raw, :o, 1},
      {21, :field_21, :raw, :o, 1},
      {22, :field_22, :raw, :o, 1},
      {23, :field_23, :raw, :o, 1},
      {24, :field_24, :raw, :o, 1},
      {25, :field_25, :raw, :o, 1}
    ]
end
