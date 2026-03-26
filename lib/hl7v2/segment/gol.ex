defmodule HL7v2.Segment.GOL do
  @moduledoc """
  Goal Detail (GOL) segment -- HL7v2 v2.5.1.

  Contains goal information for patient care plans.
  21 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "GOL",
    fields: [
      {1, :action_code, HL7v2.Type.ID, :r, 1},
      {2, :action_date_time, HL7v2.Type.TS, :r, 1},
      {3, :goal_id, HL7v2.Type.CE, :r, 1},
      {4, :goal_instance_id, HL7v2.Type.EI, :r, 1},
      {5, :episode_of_care_id, HL7v2.Type.EI, :o, 1},
      {6, :goal_list_priority, HL7v2.Type.NM, :o, 1},
      {7, :goal_established_date_time, HL7v2.Type.TS, :o, 1},
      {8, :expected_goal_achieve_date_time, HL7v2.Type.TS, :o, 1},
      {9, :goal_classification, HL7v2.Type.CE, :o, 1},
      {10, :goal_management_discipline, HL7v2.Type.CE, :o, 1},
      {11, :current_goal_review_status, HL7v2.Type.CE, :o, 1},
      {12, :current_goal_review_date_time, HL7v2.Type.TS, :o, 1},
      {13, :next_goal_review_date_time, HL7v2.Type.TS, :o, 1},
      {14, :previous_goal_review_date_time, HL7v2.Type.TS, :o, 1},
      {15, :goal_review_interval, HL7v2.Type.TQ, :o, 1},
      {16, :goal_evaluation, HL7v2.Type.CE, :o, 1},
      {17, :goal_evaluation_comment, HL7v2.Type.ST, :o, :unbounded},
      {18, :goal_life_cycle_status, HL7v2.Type.CE, :o, 1},
      {19, :goal_life_cycle_status_date_time, HL7v2.Type.TS, :o, 1},
      {20, :goal_target_type, HL7v2.Type.CE, :o, :unbounded},
      {21, :goal_target_name, HL7v2.Type.XPN, :o, :unbounded}
    ]
end
