defmodule HL7v2.Segment.TCC do
  @moduledoc """
  Test Code Configuration (TCC) segment -- HL7v2 v2.5.1.

  Contains test code configuration information for laboratory automation.
  14 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "TCC",
    fields: [
      {1, :universal_service_identifier, HL7v2.Type.CE, :r, 1},
      {2, :test_application_identifier, HL7v2.Type.EI, :r, 1},
      {3, :specimen_source, HL7v2.Type.SPS, :o, 1},
      {4, :auto_dilution_factor_default, HL7v2.Type.SN, :o, 1},
      {5, :rerun_dilution_factor_default, HL7v2.Type.SN, :o, 1},
      {6, :pre_dilution_factor_default, HL7v2.Type.SN, :o, 1},
      {7, :endogenous_content_of_pre_dilution_diluent, HL7v2.Type.SN, :o, 1},
      {8, :inventory_limits_warning_level, HL7v2.Type.NM, :o, 1},
      {9, :automatic_rerun_allowed, HL7v2.Type.ID, :o, 1},
      {10, :automatic_repeat_allowed, HL7v2.Type.ID, :o, 1},
      {11, :automatic_reflex_allowed, HL7v2.Type.ID, :o, 1},
      {12, :equipment_dynamic_range, HL7v2.Type.SN, :o, 1},
      {13, :units, HL7v2.Type.CE, :o, 1},
      {14, :processing_type, HL7v2.Type.CE, :o, 1}
    ]
end
