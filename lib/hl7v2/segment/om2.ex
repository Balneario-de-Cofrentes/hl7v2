defmodule HL7v2.Segment.OM2 do
  @moduledoc """
  Numeric Observation (OM2) segment -- HL7v2 v2.5.1.

  Contains attributes of observations with numeric values.
  10 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "OM2",
    fields: [
      {1, :sequence_number, HL7v2.Type.NM, :o, 1},
      {2, :units_of_measure, HL7v2.Type.CE, :o, 1},
      {3, :range_of_decimal_precision, HL7v2.Type.NM, :o, :unbounded},
      {4, :corresponding_si_units_of_measure, HL7v2.Type.CE, :o, 1},
      {5, :si_conversion_factor, HL7v2.Type.TX, :o, 1},
      {6, :reference_normal_range_ordinal_and_continuous_observations, HL7v2.Type.RFR, :o,
       :unbounded},
      {7, :critical_range_for_ordinal_and_continuous_observations, HL7v2.Type.RFR, :o,
       :unbounded},
      {8, :absolute_range_for_ordinal_and_continuous_observations, HL7v2.Type.RFR, :o, 1},
      {9, :delta_check_criteria, HL7v2.Type.DLT, :o, :unbounded},
      {10, :minimum_meaningful_increments, HL7v2.Type.NM, :o, 1}
    ]
end
