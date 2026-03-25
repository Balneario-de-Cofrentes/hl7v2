defmodule HL7v2.Segment.MFA do
  @moduledoc """
  Master File Acknowledgment (MFA) segment -- HL7v2 v2.5.1.

  Contains acknowledgment information for master file notifications.
  6 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "MFA",
    fields: [
      {1, :record_level_event_code, HL7v2.Type.ID, :r, 1},
      {2, :mfn_control_id, HL7v2.Type.ST, :c, 1},
      {3, :event_completion_date_time, HL7v2.Type.TS, :o, 1},
      {4, :mfn_record_level_error_return, HL7v2.Type.CE, :r, 1},
      {5, :primary_key_value_mfe, HL7v2.Type.CE, :r, :unbounded},
      {6, :primary_key_value_type_mfe, HL7v2.Type.ID, :r, :unbounded}
    ]
end
