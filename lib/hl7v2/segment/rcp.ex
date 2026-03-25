defmodule HL7v2.Segment.RCP do
  @moduledoc """
  Response Control Parameter (RCP) segment -- HL7v2 v2.5.1.

  Contains response control parameters for queries.
  7 fields per HL7 v2.5.1 specification. SRT type is unsupported;
  field 6 uses :raw.
  """

  use HL7v2.Segment,
    id: "RCP",
    fields: [
      {1, :query_priority, HL7v2.Type.ID, :o, 1},
      {2, :quantity_limited_request, HL7v2.Type.CQ, :o, 1},
      {3, :response_modality, HL7v2.Type.CE, :o, 1},
      {4, :execution_and_delivery_time, HL7v2.Type.TS, :o, 1},
      {5, :modify_indicator, HL7v2.Type.ID, :o, 1},
      {6, :sort_by_field, :raw, :o, :unbounded},
      {7, :segment_group_inclusion, HL7v2.Type.ST, :o, :unbounded}
    ]
end
