defmodule HL7v2.Segment.ORC do
  @moduledoc """
  Common Order (ORC) segment — HL7v2 v2.5.1.

  Contains order header information common to all orders.
  31 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "ORC",
    fields: [
      {1, :order_control, HL7v2.Type.ID, :r, 1},
      {2, :placer_order_number, HL7v2.Type.EI, :c, 1},
      {3, :filler_order_number, HL7v2.Type.EI, :c, 1},
      {4, :placer_group_number, HL7v2.Type.EI, :o, 1},
      {5, :order_status, HL7v2.Type.ID, :o, 1},
      {6, :response_flag, HL7v2.Type.ID, :o, 1},
      {7, :quantity_timing, HL7v2.Type.TQ, :b, :unbounded},
      {8, :parent, HL7v2.Type.EIP, :o, 1},
      {9, :date_time_of_transaction, HL7v2.Type.TS, :o, 1},
      {10, :entered_by, HL7v2.Type.XCN, :o, :unbounded},
      {11, :verified_by, HL7v2.Type.XCN, :o, :unbounded},
      {12, :ordering_provider, HL7v2.Type.XCN, :o, :unbounded},
      {13, :enterers_location, HL7v2.Type.PL, :o, 1},
      {14, :call_back_phone_number, HL7v2.Type.XTN, :o, :unbounded},
      {15, :order_effective_date_time, HL7v2.Type.TS, :o, 1},
      {16, :order_control_code_reason, HL7v2.Type.CE, :o, 1},
      {17, :entering_organization, HL7v2.Type.CE, :o, 1},
      {18, :entering_device, HL7v2.Type.CE, :o, 1},
      {19, :action_by, HL7v2.Type.XCN, :o, :unbounded},
      {20, :advanced_beneficiary_notice_code, HL7v2.Type.CE, :o, 1},
      {21, :ordering_facility_name, HL7v2.Type.XON, :o, :unbounded},
      {22, :ordering_facility_address, HL7v2.Type.XAD, :o, :unbounded},
      {23, :ordering_facility_phone_number, HL7v2.Type.XTN, :o, :unbounded},
      {24, :ordering_provider_address, HL7v2.Type.XAD, :o, :unbounded},
      {25, :order_status_modifier, HL7v2.Type.CWE, :o, 1},
      {26, :advanced_beneficiary_notice_override_reason, HL7v2.Type.CWE, :o, 1},
      {27, :fillers_expected_availability_date_time, HL7v2.Type.TS, :o, 1},
      {28, :confidentiality_code, HL7v2.Type.CWE, :o, 1},
      {29, :order_type, HL7v2.Type.CWE, :o, 1},
      {30, :enterer_authorization_mode, HL7v2.Type.CNE, :o, 1},
      {31, :parent_universal_service_identifier, HL7v2.Type.CWE, :o, 1}
    ]
end
