defmodule HL7v2.Segment.MSA do
  @moduledoc """
  Message Acknowledgment (MSA) segment — HL7v2 v2.5.1.

  Sent in response to a message to indicate receipt and processing status.
  6 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "MSA",
    fields: [
      {1, :acknowledgment_code, HL7v2.Type.ID, :r, 1},
      {2, :message_control_id, HL7v2.Type.ST, :r, 1},
      {3, :text_message, HL7v2.Type.ST, :o, 1},
      {4, :expected_sequence_number, HL7v2.Type.NM, :o, 1},
      {5, :delayed_acknowledgment_type, HL7v2.Type.ID, :b, 1},
      {6, :error_condition, HL7v2.Type.CE, :b, 1}
    ]
end
