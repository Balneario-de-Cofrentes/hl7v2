defmodule HL7v2.Segment.UB1 do
  @moduledoc """
  UB82 (UB1) segment — HL7v2 v2.5.1.

  Contains UB82 billing data. Most fields are withdrawn or backward-compatible.
  Only a handful remain typed; the rest use `:raw` for lossless round-trip.

  23 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "UB1",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :o, 1},
      {2, :field_2, :raw, :b, 1},
      {3, :field_3, :raw, :b, 1},
      {4, :field_4, :raw, :b, 1},
      {5, :field_5, :raw, :b, 1},
      {6, :field_6, :raw, :b, 1},
      {7, :condition_code, HL7v2.Type.IS, :o, 7},
      {8, :field_8, :raw, :b, 1},
      {9, :field_9, :raw, :b, 1},
      {10, :field_10, :raw, :b, 1},
      {11, :field_11, :raw, :b, 1},
      {12, :field_12, :raw, :b, 1},
      {13, :field_13, :raw, :b, 1},
      {14, :priority, HL7v2.Type.ID, :o, 1},
      {15, :field_15, :raw, :b, 1},
      {16, :number_of_grace_days, HL7v2.Type.NM, :o, 1},
      {17, :field_17, :raw, :b, 1},
      {18, :field_18, :raw, :b, 1},
      {19, :field_19, :raw, :b, 1},
      {20, :field_20, :raw, :b, 1},
      {21, :field_21, :raw, :b, 1},
      {22, :field_22, :raw, :b, 1},
      {23, :field_23, :raw, :b, 1}
    ]
end
