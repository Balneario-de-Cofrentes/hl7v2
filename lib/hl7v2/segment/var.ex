defmodule HL7v2.Segment.VAR do
  @moduledoc """
  Variance (VAR) segment — HL7v2 v2.5.1.

  Defines variances from a clinical pathway or protocol.

  6 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "VAR",
    fields: [
      {1, :variance_instance_id, HL7v2.Type.EI, :r, 1},
      {2, :documented_date_time, HL7v2.Type.TS, :r, 1},
      {3, :stated_variance_date_time, HL7v2.Type.TS, :o, 1},
      {4, :variance_originator, HL7v2.Type.XCN, :o, :unbounded},
      {5, :variance_classification, HL7v2.Type.CE, :o, 1},
      {6, :variance_description, HL7v2.Type.ST, :o, :unbounded}
    ]
end
