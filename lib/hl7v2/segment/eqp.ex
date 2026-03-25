defmodule HL7v2.Segment.EQP do
  @moduledoc """
  Equipment Log Service (EQP) segment — HL7v2 v2.5.1.

  Contains log/service event information for equipment.

  5 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "EQP",
    fields: [
      {1, :event_type, HL7v2.Type.CE, :r, 1},
      {2, :file_name, HL7v2.Type.ST, :o, 1},
      {3, :start_date_time, HL7v2.Type.TS, :r, 1},
      {4, :end_date_time, HL7v2.Type.TS, :o, 1},
      {5, :transaction_data, HL7v2.Type.FT, :r, 1}
    ]
end
