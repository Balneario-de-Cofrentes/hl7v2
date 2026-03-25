defmodule HL7v2.Segment.SCD do
  @moduledoc """
  Anti-Microbial Cycle Data (SCD) segment -- HL7v2 v2.5.1.

  Contains anti-microbial cycle data for sterilization.
  36 fields per HL7 v2.5.1 specification. Fields 1-20 are typed,
  fields 21-36 use :raw.
  """

  use HL7v2.Segment,
    id: "SCD",
    fields: [
      {1, :cycle_start_time, HL7v2.Type.TS, :o, 1},
      {2, :cycle_count, HL7v2.Type.NM, :o, 1},
      {3, :temp_max, HL7v2.Type.CQ, :o, 1},
      {4, :temp_min, HL7v2.Type.CQ, :o, 1},
      {5, :load_number, HL7v2.Type.NM, :o, 1},
      {6, :condition_time, HL7v2.Type.CQ, :o, 1},
      {7, :sterilize_time, HL7v2.Type.CQ, :o, 1},
      {8, :exhaust_time, HL7v2.Type.CQ, :o, 1},
      {9, :total_cycle_time, HL7v2.Type.CQ, :o, 1},
      {10, :device_status, HL7v2.Type.CWE, :o, 1},
      {11, :cycle_start_date_time, HL7v2.Type.TS, :o, 1},
      {12, :dry_time, HL7v2.Type.CQ, :o, 1},
      {13, :leak_rate, HL7v2.Type.CQ, :o, 1},
      {14, :control_temperature, HL7v2.Type.CQ, :o, 1},
      {15, :sterilizer_temperature, HL7v2.Type.CQ, :o, 1},
      {16, :cycle_complete_time, HL7v2.Type.TS, :o, 1},
      {17, :under_temperature, HL7v2.Type.CQ, :o, 1},
      {18, :over_temperature, HL7v2.Type.CQ, :o, 1},
      {19, :abort_cycle, HL7v2.Type.CNE, :o, 1},
      {20, :alarm, HL7v2.Type.CNE, :o, 1},
      {21, :field_21, :raw, :o, 1},
      {22, :field_22, :raw, :o, 1},
      {23, :field_23, :raw, :o, 1},
      {24, :field_24, :raw, :o, 1},
      {25, :field_25, :raw, :o, 1},
      {26, :field_26, :raw, :o, 1},
      {27, :field_27, :raw, :o, 1},
      {28, :field_28, :raw, :o, 1},
      {29, :field_29, :raw, :o, 1},
      {30, :field_30, :raw, :o, 1},
      {31, :field_31, :raw, :o, 1},
      {32, :field_32, :raw, :o, 1},
      {33, :field_33, :raw, :o, 1},
      {34, :field_34, :raw, :o, 1},
      {35, :field_35, :raw, :o, 1},
      {36, :field_36, :raw, :o, 1}
    ]
end
