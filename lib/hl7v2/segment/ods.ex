defmodule HL7v2.Segment.ODS do
  @moduledoc """
  Dietary Orders, Supplements, and Preferences (ODS) segment -- HL7v2 v2.5.1.

  Contains dietary orders, supplements, and preferences.

  4 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "ODS",
    fields: [
      {1, :type, HL7v2.Type.ID, :r, 1},
      {2, :service_period, HL7v2.Type.CE, :o, :unbounded},
      {3, :diet_supplement_or_preference_code, HL7v2.Type.CE, :r, :unbounded},
      {4, :text_instruction, HL7v2.Type.ST, :o, :unbounded}
    ]
end
