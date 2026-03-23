defmodule HL7v2.Segment.ROL do
  @moduledoc """
  Role (ROL) segment — HL7v2 v2.5.1.

  Communicates role information for providers associated with a patient
  encounter. Appears in ADT_A01 PATIENT, VISIT, PROCEDURE, and INSURANCE
  groups.

  12 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "ROL",
    fields: [
      {1, :role_instance_id, HL7v2.Type.EI, :o, 1},
      {2, :action_code, HL7v2.Type.ID, :r, 1},
      {3, :role, HL7v2.Type.CE, :r, 1},
      {4, :role_person, HL7v2.Type.XCN, :r, :unbounded},
      {5, :role_begin_date_time, HL7v2.Type.TS, :o, 1},
      {6, :role_end_date_time, HL7v2.Type.TS, :o, 1},
      {7, :role_duration, HL7v2.Type.CE, :o, 1},
      {8, :role_action_reason, HL7v2.Type.CE, :o, 1},
      {9, :provider_type, HL7v2.Type.CE, :o, :unbounded},
      {10, :organization_unit_type, HL7v2.Type.CE, :o, 1},
      {11, :office_home_address_birthplace, HL7v2.Type.XAD, :o, :unbounded},
      {12, :phone, HL7v2.Type.XTN, :o, :unbounded}
    ]
end
