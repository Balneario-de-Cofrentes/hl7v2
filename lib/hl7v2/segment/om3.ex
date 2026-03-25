defmodule HL7v2.Segment.OM3 do
  @moduledoc """
  Categorical Service/Test/Observation (OM3) segment -- HL7v2 v2.5.1.

  Contains attributes of observations with categorical results.
  7 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "OM3",
    fields: [
      {1, :sequence_number, HL7v2.Type.NM, :o, 1},
      {2, :preferred_coding_system, HL7v2.Type.CE, :o, 1},
      {3, :valid_coded_answers, HL7v2.Type.CE, :o, :unbounded},
      {4, :normal_text_codes_for_categorical_results, HL7v2.Type.CE, :o, :unbounded},
      {5, :abnormal_text_codes_for_categorical_results, HL7v2.Type.CE, :o, :unbounded},
      {6, :critical_text_codes_for_categorical_results, HL7v2.Type.CE, :o, :unbounded},
      {7, :value_type, HL7v2.Type.ID, :o, 1}
    ]
end
