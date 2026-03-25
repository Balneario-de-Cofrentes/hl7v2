defmodule HL7v2.Segment.SPR do
  @moduledoc """
  Stored Procedure Request Definition (SPR) segment -- HL7v2 v2.5.1.

  Withdrawn/deprecated query segment from v2.3 that still appears in the
  v2.5.1 index. Defines a stored procedure request.

  4 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "SPR",
    fields: [
      {1, :query_tag, HL7v2.Type.ST, :o, 1},
      {2, :query_response_format_code, HL7v2.Type.ID, :r, 1},
      {3, :stored_procedure_name, HL7v2.Type.CE, :r, 1},
      {4, :input_parameter_list, HL7v2.Type.QIP, :o, :unbounded}
    ]
end
