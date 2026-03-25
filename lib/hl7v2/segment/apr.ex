defmodule HL7v2.Segment.APR do
  @moduledoc """
  Appointment Preferences (APR) segment -- HL7v2 v2.5.1.

  Contains preferences for scheduling appointments.
  5 fields per HL7 v2.5.1 specification. SCV type is unsupported; fields use :raw.
  """

  use HL7v2.Segment,
    id: "APR",
    fields: [
      {1, :time_selection_criteria, :raw, :o, :unbounded},
      {2, :resource_selection_criteria, :raw, :o, :unbounded},
      {3, :location_selection_criteria, :raw, :o, :unbounded},
      {4, :slot_spacing_criteria, HL7v2.Type.NM, :o, 1},
      {5, :filler_override_criteria, :raw, :o, :unbounded}
    ]
end
