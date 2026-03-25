defmodule HL7v2.Segment.QID do
  @moduledoc """
  Query Identification (QID) segment — HL7v2 v2.5.1.

  Used to identify a query instance for query-by-parameter messages.

  2 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "QID",
    fields: [
      {1, :query_tag, HL7v2.Type.ST, :r, 1},
      {2, :message_query_name, HL7v2.Type.CE, :r, 1}
    ]
end
