defmodule HL7v2.Segment.SCD do
  @moduledoc """
  Anti-Microbial Cycle Data (SCD) segment -- HL7v2 v2.5.1.

  Contains anti-microbial cycle data for sterilization.
  36 fields per HL7 v2.5.1 specification.
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
      {21, :long_in_charge_phase, HL7v2.Type.CNE, :o, 1},
      {22, :long_in_exhaust_phase, HL7v2.Type.CNE, :o, 1},
      {23, :long_in_fast_exhaust_phase, HL7v2.Type.CNE, :o, 1},
      {24, :reset, HL7v2.Type.CNE, :o, 1},
      {25, :operator_unload, HL7v2.Type.XCN, :o, 1},
      {26, :door_open, HL7v2.Type.CNE, :o, 1},
      {27, :reading_failure, HL7v2.Type.CNE, :o, 1},
      {28, :cycle_type, HL7v2.Type.CWE, :o, 1},
      {29, :thermal_rinse_time, HL7v2.Type.CQ, :o, 1},
      {30, :wash_time, HL7v2.Type.CQ, :o, 1},
      {31, :injection_rate, HL7v2.Type.CQ, :o, 1},
      {32, :procedure_code, HL7v2.Type.CNE, :o, 1},
      {33, :patient_identifier_list, HL7v2.Type.CX, :o, :unbounded},
      {34, :attending_doctor, HL7v2.Type.XCN, :o, 1},
      {35, :dilution_factor, HL7v2.Type.SN, :o, 1},
      {36, :fill_time, HL7v2.Type.CQ, :o, 1}
    ]
end
