defmodule HL7v2.Segment.STF do
  @moduledoc """
  Staff Identification (STF) segment -- HL7v2 v2.5.1.

  Contains staff identification information.
  38 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "STF",
    fields: [
      {1, :primary_key_value, HL7v2.Type.CE, :c, 1},
      {2, :staff_identifier_list, HL7v2.Type.CX, :o, :unbounded},
      {3, :staff_name, HL7v2.Type.XPN, :o, :unbounded},
      {4, :staff_type, HL7v2.Type.IS, :o, :unbounded},
      {5, :administrative_sex, HL7v2.Type.IS, :o, 1},
      {6, :date_time_of_birth, HL7v2.Type.TS, :o, 1},
      {7, :active_inactive_flag, HL7v2.Type.ID, :o, 1},
      {8, :department, HL7v2.Type.CE, :o, :unbounded},
      {9, :hospital_service, HL7v2.Type.CE, :o, :unbounded},
      {10, :phone, HL7v2.Type.XTN, :o, :unbounded},
      {11, :office_home_address_birthplace, HL7v2.Type.XAD, :o, :unbounded},
      {12, :institution_activation_date, HL7v2.Type.DIN, :o, :unbounded},
      {13, :institution_inactivation_date, HL7v2.Type.DIN, :o, :unbounded},
      {14, :backup_person_id, HL7v2.Type.CE, :o, :unbounded},
      {15, :e_mail_address, HL7v2.Type.ST, :o, :unbounded},
      {16, :preferred_method_of_contact, HL7v2.Type.CE, :o, 1},
      {17, :marital_status, HL7v2.Type.CE, :o, 1},
      {18, :job_title, HL7v2.Type.ST, :o, 1},
      {19, :job_code_class, HL7v2.Type.JCC, :o, 1},
      {20, :employment_status_code, HL7v2.Type.CE, :o, 1},
      {21, :additional_insured_on_auto, HL7v2.Type.ID, :o, 1},
      {22, :drivers_license_number_staff, HL7v2.Type.DLN, :o, 1},
      {23, :copy_auto_ins, HL7v2.Type.ID, :o, 1},
      {24, :auto_ins_expires, HL7v2.Type.DT, :o, 1},
      {25, :date_last_dmv_review, HL7v2.Type.DT, :o, 1},
      {26, :date_next_dmv_review, HL7v2.Type.DT, :o, 1},
      {27, :race, HL7v2.Type.CE, :o, 1},
      {28, :ethnic_group, HL7v2.Type.CE, :o, 1},
      {29, :re_activation_approval_indicator, HL7v2.Type.ID, :o, 1},
      {30, :citizenship, HL7v2.Type.CE, :o, :unbounded},
      {31, :death_date_and_time, HL7v2.Type.TS, :o, 1},
      {32, :death_indicator, HL7v2.Type.ID, :o, 1},
      {33, :institution_relationship_type_code, HL7v2.Type.CWE, :o, 1},
      {34, :institution_relationship_period, HL7v2.Type.DR, :o, 1},
      {35, :expected_return_date, HL7v2.Type.DT, :o, 1},
      {36, :cost_center_code, HL7v2.Type.CWE, :o, :unbounded},
      {37, :generic_classification_indicator, HL7v2.Type.ID, :o, 1},
      {38, :inactive_reason_code, HL7v2.Type.CWE, :o, 1}
    ]
end
