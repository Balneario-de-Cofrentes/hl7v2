defmodule HL7v2.Segment.QRI do
  @moduledoc """
  Query Response Instance (QRI) segment -- HL7v2 v2.5.1.

  Contains information about the confidence and matching of a query response.

  3 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "QRI",
    fields: [
      {1, :candidate_confidence, HL7v2.Type.NM, :o, 1},
      {2, :match_reason_code, HL7v2.Type.IS, :o, :unbounded},
      {3, :algorithm_descriptor, HL7v2.Type.CE, :o, 1}
    ]
end
