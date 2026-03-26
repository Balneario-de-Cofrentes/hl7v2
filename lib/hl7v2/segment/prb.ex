defmodule HL7v2.Segment.PRB do
  @moduledoc """
  Problem Details (PRB) segment -- HL7v2 v2.5.1.

  Contains problem detail information.
  25 fields per HL7 v2.5.1 specification.
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
      {16, :problem_date_of_onset, HL7v2.Type.TS, :o, 1},
      {17, :problem_onset_text, HL7v2.Type.ST, :o, 1},
      {18, :problem_ranking, HL7v2.Type.CE, :o, 1},
      {19, :certainty_of_problem, HL7v2.Type.CE, :o, 1},
      {20, :probability_of_problem, HL7v2.Type.NM, :o, 1},
      {21, :individual_awareness_of_problem, HL7v2.Type.CE, :o, 1},
      {22, :problem_prognosis, HL7v2.Type.CE, :o, 1},
      {23, :individual_awareness_of_prognosis, HL7v2.Type.CE, :o, 1},
      {24, :family_significant_other_awareness_of_problem_prognosis, HL7v2.Type.ST, :o, 1},
      {25, :security_sensitivity, HL7v2.Type.CE, :o, 1}
    ]
end
