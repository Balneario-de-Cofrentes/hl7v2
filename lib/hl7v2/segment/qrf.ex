defmodule HL7v2.Segment.QRF do
  @moduledoc """
  Original Style Query Filter (QRF) segment -- HL7v2 v2.5.1.

  Contains original style query filter information.
  10 fields per HL7 v2.5.1 specification. TQ type at field 9 uses
  the existing typed support.
  """

  use HL7v2.Segment,
    id: "QRF",
    fields: [
      {1, :where_subject_filter, HL7v2.Type.ST, :r, :unbounded},
      {2, :when_data_start_date_time, HL7v2.Type.TS, :o, 1},
      {3, :when_data_end_date_time, HL7v2.Type.TS, :o, 1},
      {4, :what_user_qualifier, HL7v2.Type.ST, :o, :unbounded},
      {5, :other_qry_subject_filter, HL7v2.Type.ST, :o, :unbounded},
      {6, :which_date_time_qualifier, HL7v2.Type.ID, :o, :unbounded},
      {7, :which_date_time_status_qualifier, HL7v2.Type.ID, :o, :unbounded},
      {8, :date_time_selection_qualifier, HL7v2.Type.ID, :o, :unbounded},
      {9, :when_quantity_timing_qualifier, HL7v2.Type.TQ, :o, 1},
      {10, :search_confidence_threshold, HL7v2.Type.NM, :o, 1}
    ]
end
