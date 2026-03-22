defmodule HL7v2.Segment.OBX do
  @moduledoc """
  Observation/Result (OBX) segment — HL7v2 v2.5.1.

  Carries a single observation value. OBX-5 type varies based on OBX-2 (Value Type).
  19 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "OBX",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :o, 1},
      {2, :value_type, HL7v2.Type.ID, :c, 1},
      {3, :observation_identifier, HL7v2.Type.CE, :r, 1},
      {4, :observation_sub_id, HL7v2.Type.ST, :c, 1},
      {5, :observation_value, :raw, :c, :unbounded},
      {6, :units, HL7v2.Type.CE, :o, 1},
      {7, :references_range, HL7v2.Type.ST, :o, 1},
      {8, :abnormal_flags, HL7v2.Type.IS, :o, :unbounded},
      {9, :probability, HL7v2.Type.NM, :o, 1},
      {10, :nature_of_abnormal_test, HL7v2.Type.ID, :o, :unbounded},
      {11, :observation_result_status, HL7v2.Type.ID, :r, 1},
      {12, :effective_date_of_reference_range, HL7v2.Type.TS, :o, 1},
      {13, :user_defined_access_checks, HL7v2.Type.ST, :o, 1},
      {14, :date_time_of_the_observation, HL7v2.Type.TS, :o, 1},
      {15, :producers_id, HL7v2.Type.CE, :o, 1},
      {16, :responsible_observer, :raw, :o, :unbounded},
      {17, :observation_method, HL7v2.Type.CE, :o, :unbounded},
      {18, :equipment_instance_identifier, HL7v2.Type.EI, :o, :unbounded},
      {19, :date_time_of_the_analysis, HL7v2.Type.TS, :o, 1}
    ]
end
