defmodule HL7v2.Segment.RXC do
  @moduledoc """
  Pharmacy/Treatment Component Order (RXC) segment — HL7v2 v2.5.1.

  Describes individual components of a compound medication order (base, additives).
  9 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "RXC",
    fields: [
      {1, :rx_component_type, HL7v2.Type.ID, :r, 1},
      {2, :component_code, HL7v2.Type.CE, :r, 1},
      {3, :component_amount, HL7v2.Type.NM, :r, 1},
      {4, :component_units, HL7v2.Type.CE, :r, 1},
      {5, :component_strength, HL7v2.Type.NM, :o, 1},
      {6, :component_strength_units, HL7v2.Type.CE, :o, 1},
      {7, :supplementary_code, HL7v2.Type.CE, :o, :unbounded},
      {8, :component_drug_strength_volume, HL7v2.Type.NM, :o, 1},
      {9, :component_drug_strength_volume_units, HL7v2.Type.CWE, :o, 1}
    ]
end
