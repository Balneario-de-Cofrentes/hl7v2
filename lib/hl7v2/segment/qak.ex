defmodule HL7v2.Segment.QAK do
  @moduledoc """
  Query Acknowledgment (QAK) segment -- HL7v2 v2.5.1.

  Contains query acknowledgment information.
  6 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "QAK",
    fields: [
      {1, :query_tag, HL7v2.Type.ST, :c, 1},
      {2, :query_response_status, HL7v2.Type.ID, :o, 1},
      {3, :message_query_name, HL7v2.Type.CE, :o, 1},
      {4, :hit_count_total, HL7v2.Type.NM, :o, 1},
      {5, :this_payload, HL7v2.Type.NM, :o, 1},
      {6, :hits_remaining, HL7v2.Type.NM, :o, 1}
    ]
end
