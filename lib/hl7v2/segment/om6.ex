defmodule HL7v2.Segment.OM6 do
  @moduledoc """
  Observations Calculated from Others (OM6) segment -- HL7v2 v2.5.1.

  Contains the derivation rule for calculated observations.
  1 field per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "OM6",
    fields: [
      {1, :derivation_rule, HL7v2.Type.TX, :o, 1}
    ]
end
