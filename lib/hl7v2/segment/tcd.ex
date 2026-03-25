defmodule HL7v2.Segment.TCD do
  @moduledoc """
  Test Code Detail (TCD) segment -- HL7v2 v2.5.1.

  Contains test code detail information for laboratory automation.
  8 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "TCD",
    fields: [
      {1, :universal_service_identifier, HL7v2.Type.CE, :r, 1},
      {2, :auto_dilution_factor, HL7v2.Type.SN, :o, 1},
      {3, :rerun_dilution_factor, HL7v2.Type.SN, :o, 1},
      {4, :pre_dilution_factor, HL7v2.Type.SN, :o, 1},
      {5, :endogenous_content_of_pre_dilution_diluent, HL7v2.Type.SN, :o, 1},
      {6, :automatic_repeat_allowed, HL7v2.Type.ID, :o, 1},
      {7, :reflex_allowed, HL7v2.Type.ID, :o, 1},
      {8, :analyte_repeatability, HL7v2.Type.CE, :o, 1}
    ]
end
