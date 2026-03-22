defmodule HL7v2.Segment.ERR do
  @moduledoc """
  Error (ERR) segment — HL7v2 v2.5.1.

  Identifies errors in a received message. 12 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "ERR",
    fields: [
      {1, :error_code_and_location, :raw, :b, :unbounded},
      {2, :error_location, :raw, :o, :unbounded},
      {3, :hl7_error_code, HL7v2.Type.CWE, :r, 1},
      {4, :severity, HL7v2.Type.ID, :r, 1},
      {5, :application_error_code, HL7v2.Type.CWE, :o, 1},
      {6, :application_error_parameter, HL7v2.Type.ST, :o, :unbounded},
      {7, :diagnostic_information, HL7v2.Type.TX, :o, 1},
      {8, :user_message, HL7v2.Type.TX, :o, 1},
      {9, :inform_person_indicator, HL7v2.Type.IS, :o, :unbounded},
      {10, :override_type, HL7v2.Type.CWE, :o, 1},
      {11, :override_reason_code, HL7v2.Type.CWE, :o, :unbounded},
      {12, :help_desk_contact_point, HL7v2.Type.XTN, :o, :unbounded}
    ]
end
