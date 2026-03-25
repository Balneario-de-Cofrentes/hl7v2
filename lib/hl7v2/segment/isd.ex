defmodule HL7v2.Segment.ISD do
  @moduledoc """
  Interaction Status Detail (ISD) segment -- HL7v2 v2.5.1.

  Contains interaction status detail for laboratory automation.
  3 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "ISD",
    fields: [
      {1, :reference_interaction_number, HL7v2.Type.NM, :r, 1},
      {2, :interaction_type_identifier, HL7v2.Type.CE, :o, 1},
      {3, :interaction_active_state, HL7v2.Type.CE, :r, 1}
    ]
end
