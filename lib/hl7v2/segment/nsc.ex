defmodule HL7v2.Segment.NSC do
  @moduledoc """
  Application Status Change (NSC) segment -- HL7v2 v2.5.1.

  Contains information about application status changes.

  9 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "NSC",
    fields: [
      {1, :application_change_type, HL7v2.Type.IS, :r, 1},
      {2, :current_cpu, HL7v2.Type.ST, :o, 1},
      {3, :current_fileserver, HL7v2.Type.ST, :o, 1},
      {4, :current_application, HL7v2.Type.HD, :o, 1},
      {5, :current_facility, HL7v2.Type.HD, :o, 1},
      {6, :new_cpu, HL7v2.Type.ST, :o, 1},
      {7, :new_fileserver, HL7v2.Type.ST, :o, 1},
      {8, :new_application, HL7v2.Type.HD, :o, 1},
      {9, :new_facility, HL7v2.Type.HD, :o, 1}
    ]
end
