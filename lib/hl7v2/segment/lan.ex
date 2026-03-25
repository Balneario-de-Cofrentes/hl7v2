defmodule HL7v2.Segment.LAN do
  @moduledoc """
  Language Detail (LAN) segment -- HL7v2 v2.5.1.

  Contains language ability information for staff members.
  4 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "LAN",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :r, 1},
      {2, :language_code, HL7v2.Type.CE, :r, 1},
      {3, :language_ability_code, HL7v2.Type.CE, :o, :unbounded},
      {4, :language_proficiency_code, HL7v2.Type.CE, :o, 1}
    ]
end
