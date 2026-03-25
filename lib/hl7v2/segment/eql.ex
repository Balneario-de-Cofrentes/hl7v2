defmodule HL7v2.Segment.EQL do
  @moduledoc """
  Embedded Query Language (EQL) segment -- HL7v2 v2.5.1.

  Withdrawn/deprecated query segment from v2.3 that still appears in the
  v2.5.1 index. Carries an embedded query statement.

  4 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "EQL",
    fields: [
      {1, :query_tag, HL7v2.Type.ST, :o, 1},
      {2, :query_response_format_code, HL7v2.Type.ID, :r, 1},
      {3, :eql_query_name, HL7v2.Type.CE, :r, 1},
      {4, :eql_query_statement, HL7v2.Type.ST, :r, 1}
    ]
end
