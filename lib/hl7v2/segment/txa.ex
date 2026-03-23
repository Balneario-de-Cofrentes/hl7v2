defmodule HL7v2.Segment.TXA do
  @moduledoc """
  Transcription Document Header (TXA) segment -- HL7v2 v2.5.1.

  Contains information specific to a transcribed document.
  23 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "TXA",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :r, 1},
      {2, :document_type, HL7v2.Type.IS, :r, 1},
      {3, :document_content_presentation, HL7v2.Type.ID, :o, 1},
      {4, :activity_date_time, HL7v2.Type.TS, :o, 1},
      {5, :primary_activity_provider_code, HL7v2.Type.XCN, :o, :unbounded},
      {6, :origination_date_time, HL7v2.Type.TS, :o, 1},
      {7, :transcription_date_time, HL7v2.Type.TS, :o, 1},
      {8, :edit_date_time, HL7v2.Type.TS, :o, :unbounded},
      {9, :originator_code_name, HL7v2.Type.XCN, :o, :unbounded},
      {10, :assigned_document_authenticator, HL7v2.Type.XCN, :o, :unbounded},
      {11, :transcriptionist_code_name, HL7v2.Type.XCN, :o, :unbounded},
      {12, :unique_document_number, HL7v2.Type.EI, :r, 1},
      {13, :parent_document_number, HL7v2.Type.EI, :o, 1},
      {14, :placer_order_number, HL7v2.Type.EI, :o, :unbounded},
      {15, :filler_order_number, HL7v2.Type.EI, :o, 1},
      {16, :unique_document_file_name, HL7v2.Type.ST, :o, 1},
      {17, :document_completion_status, HL7v2.Type.ID, :o, 1},
      {18, :document_confidentiality_status, HL7v2.Type.ID, :o, 1},
      {19, :document_availability_status, HL7v2.Type.ID, :o, 1},
      {20, :document_storage_status, HL7v2.Type.ID, :o, 1},
      {21, :document_change_reason, HL7v2.Type.ST, :o, 1},
      {22, :authentication_person_time_stamp, HL7v2.Type.XCN, :o, :unbounded},
      {23, :distributed_copies, HL7v2.Type.XCN, :o, :unbounded}
    ]
end
