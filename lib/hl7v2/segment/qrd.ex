defmodule HL7v2.Segment.QRD do
  @moduledoc """
  Original-Style Query Definition (QRD) segment -- HL7v2 v2.5.1.

  Contains original-style query definition information.
  12 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "QRD",
    fields: [
      {1, :query_date_time, HL7v2.Type.TS, :r, 1},
      {2, :query_format_code, HL7v2.Type.ID, :r, 1},
      {3, :query_priority, HL7v2.Type.ID, :r, 1},
      {4, :query_id, HL7v2.Type.ST, :r, 1},
      {5, :deferred_response_type, HL7v2.Type.ID, :o, 1},
      {6, :deferred_response_date_time, HL7v2.Type.TS, :o, 1},
      {7, :quantity_limited_request, HL7v2.Type.CQ, :r, 1},
      {8, :who_subject_filter, HL7v2.Type.XCN, :r, :unbounded},
      {9, :what_subject_filter, HL7v2.Type.CE, :r, :unbounded},
      {10, :what_department_data_code, HL7v2.Type.CE, :r, :unbounded},
      {11, :what_data_code_value_qual, HL7v2.Type.VR, :o, :unbounded},
      {12, :query_results_level, HL7v2.Type.ID, :o, 1}
    ]
end
