defmodule HL7v2.Segment.ODT do
  @moduledoc """
  Diet Tray Instructions (ODT) segment -- HL7v2 v2.5.1.

  Contains diet tray instructions.

  3 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "ODT",
    fields: [
      {1, :tray_type, HL7v2.Type.CE, :r, 1},
      {2, :service_period, HL7v2.Type.CE, :o, :unbounded},
      {3, :text_instruction, HL7v2.Type.ST, :o, 1}
    ]
end
