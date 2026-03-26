defmodule HL7v2.Segment.PSH do
  @moduledoc """
  Product Summary Header (PSH) segment -- HL7v2 v2.5.1.

  Contains product summary header information.
  14 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "PSH",
    fields: [
      {1, :report_type, HL7v2.Type.ST, :r, 1},
      {2, :report_form_identifier, HL7v2.Type.ST, :o, 1},
      {3, :report_date, HL7v2.Type.TS, :r, 1},
      {4, :report_interval_start_date, HL7v2.Type.TS, :o, 1},
      {5, :report_interval_end_date, HL7v2.Type.TS, :o, 1},
      {6, :quantity_manufactured, HL7v2.Type.CQ, :o, 1},
      {7, :quantity_distributed, HL7v2.Type.CQ, :o, 1},
      {8, :quantity_distributed_method, HL7v2.Type.ID, :o, 1},
      {9, :quantity_distributed_comment, HL7v2.Type.FT, :o, 1},
      {10, :quantity_in_use, HL7v2.Type.CQ, :o, 1},
      {11, :quantity_in_use_method, HL7v2.Type.ID, :o, 1},
      {12, :quantity_in_use_comment, HL7v2.Type.FT, :o, 1},
      {13, :number_of_product_experience_reports_filed_by_facility, HL7v2.Type.NM, :o,
       :unbounded},
      {14, :number_of_product_experience_reports_filed_by_distributor, HL7v2.Type.NM, :o,
       :unbounded}
    ]
end
