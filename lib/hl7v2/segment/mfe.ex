defmodule HL7v2.Segment.MFE do
  @moduledoc """
  Master File Entry (MFE) segment -- HL7v2 v2.5.1.

  Contains information about a single master file entry.
  5 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "MFE",
    fields: [
      {1, :record_level_event_code, HL7v2.Type.ID, :r, 1},
      {2, :mfn_control_id, HL7v2.Type.ST, :c, 1},
      {3, :effective_date_time, HL7v2.Type.TS, :o, 1},
      {4, :primary_key_value, HL7v2.Type.CE, :r, :unbounded},
      {5, :primary_key_value_type, HL7v2.Type.ID, :r, :unbounded}
    ]
end
