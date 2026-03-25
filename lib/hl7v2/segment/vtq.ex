defmodule HL7v2.Segment.VTQ do
  @moduledoc """
  Virtual Table Query Request (VTQ) segment -- HL7v2 v2.5.1.

  Withdrawn/deprecated query segment from v2.3 that still appears in the
  v2.5.1 index. Defines a virtual table query request.

  5 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "VTQ",
    fields: [
      {1, :query_tag, HL7v2.Type.ST, :o, 1},
      {2, :query_response_format_code, HL7v2.Type.ID, :r, 1},
      {3, :vtq_query_name, HL7v2.Type.CE, :r, 1},
      {4, :virtual_table_name, HL7v2.Type.CE, :r, 1},
      {5, :selection_criteria, HL7v2.Type.QSC, :o, :unbounded}
    ]
end
