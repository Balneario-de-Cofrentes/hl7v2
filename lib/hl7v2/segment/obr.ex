defmodule HL7v2.Segment.OBR do
  @moduledoc """
  Observation Request (OBR) segment — HL7v2 v2.5.1.

  Transmits information specific to an observation/test/battery request.
  49 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "OBR",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :o, 1},
      {2, :placer_order_number, HL7v2.Type.EI, :c, 1},
      {3, :filler_order_number, HL7v2.Type.EI, :c, 1},
      {4, :universal_service_identifier, HL7v2.Type.CE, :r, 1},
      {5, :priority, HL7v2.Type.ID, :b, 1},
      {6, :requested_date_time, HL7v2.Type.TS, :b, 1},
      {7, :observation_date_time, HL7v2.Type.TS, :c, 1},
      {8, :observation_end_date_time, HL7v2.Type.TS, :o, 1},
      {9, :collection_volume, HL7v2.Type.CQ, :o, 1},
      {10, :collector_identifier, HL7v2.Type.XCN, :o, :unbounded},
      {11, :specimen_action_code, HL7v2.Type.ID, :o, 1},
      {12, :danger_code, HL7v2.Type.CE, :o, 1},
      {13, :relevant_clinical_information, HL7v2.Type.ST, :o, 1},
      {14, :specimen_received_date_time, HL7v2.Type.TS, :b, 1},
      {15, :specimen_source, HL7v2.Type.SPS, :b, 1},
      {16, :ordering_provider, HL7v2.Type.XCN, :o, :unbounded},
      {17, :order_callback_phone_number, HL7v2.Type.XTN, :o, :unbounded},
      {18, :placer_field_1, HL7v2.Type.ST, :o, 1},
      {19, :placer_field_2, HL7v2.Type.ST, :o, 1},
      {20, :filler_field_1, HL7v2.Type.ST, :o, 1},
      {21, :filler_field_2, HL7v2.Type.ST, :o, 1},
      {22, :results_rpt_status_chng_date_time, HL7v2.Type.TS, :c, 1},
      {23, :charge_to_practice, HL7v2.Type.MOC, :o, 1},
      {24, :diagnostic_serv_sect_id, HL7v2.Type.ID, :o, 1},
      {25, :result_status, HL7v2.Type.ID, :c, 1},
      {26, :parent_result, HL7v2.Type.PRL, :o, 1},
      {27, :quantity_timing, HL7v2.Type.TQ, :b, :unbounded},
      {28, :result_copies_to, HL7v2.Type.XCN, :o, :unbounded},
      {29, :parent, HL7v2.Type.EIP, :o, 1},
      {30, :transportation_mode, HL7v2.Type.ID, :o, 1},
      {31, :reason_for_study, HL7v2.Type.CE, :o, :unbounded},
      {32, :principal_result_interpreter, HL7v2.Type.NDL, :o, 1},
      {33, :assistant_result_interpreter, HL7v2.Type.NDL, :o, :unbounded},
      {34, :technician, HL7v2.Type.NDL, :o, :unbounded},
      {35, :transcriptionist, HL7v2.Type.NDL, :o, :unbounded},
      {36, :scheduled_date_time, HL7v2.Type.TS, :o, 1},
      {37, :number_of_sample_containers, HL7v2.Type.NM, :o, 1},
      {38, :transport_logistics_of_collected_sample, HL7v2.Type.CE, :o, :unbounded},
      {39, :collectors_comment, HL7v2.Type.CE, :o, :unbounded},
      {40, :transport_arrangement_responsibility, HL7v2.Type.CE, :o, 1},
      {41, :transport_arranged, HL7v2.Type.ID, :o, 1},
      {42, :escort_required, HL7v2.Type.ID, :o, 1},
      {43, :planned_patient_transport_comment, HL7v2.Type.CE, :o, :unbounded},
      {44, :procedure_code, HL7v2.Type.CE, :o, 1},
      {45, :procedure_code_modifier, HL7v2.Type.CE, :o, :unbounded},
      {46, :placer_supplemental_service_information, HL7v2.Type.CE, :o, :unbounded},
      {47, :filler_supplemental_service_information, HL7v2.Type.CE, :o, :unbounded},
      {48, :medically_necessary_duplicate_procedure_reason, HL7v2.Type.CWE, :o, 1},
      {49, :result_handling, HL7v2.Type.IS, :o, 1}
    ]
end
