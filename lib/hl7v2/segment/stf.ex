defmodule HL7v2.Segment.STF do
  @moduledoc """
  Staff Identification (STF) segment -- HL7v2 v2.5.1.

  Contains staff identification information.
  38 fields per HL7 v2.5.1 specification. Fields 1-20 are typed,
  fields 21-38 use :raw.
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
      {12, :institution_activation_date, :raw, :o, :unbounded},
      {13, :institution_inactivation_date, :raw, :o, :unbounded},
      {14, :backup_person_id, HL7v2.Type.CE, :o, :unbounded},
      {15, :e_mail_address, HL7v2.Type.ST, :o, :unbounded},
      {16, :preferred_method_of_contact, HL7v2.Type.CE, :o, 1},
      {17, :marital_status, HL7v2.Type.CE, :o, 1},
      {18, :job_title, HL7v2.Type.ST, :o, 1},
      {19, :job_code_class, HL7v2.Type.JCC, :o, 1},
      {20, :employment_status_code, HL7v2.Type.CE, :o, 1},
      {21, :field_21, :raw, :o, 1},
      {22, :field_22, :raw, :o, 1},
      {23, :field_23, :raw, :o, 1},
      {24, :field_24, :raw, :o, 1},
      {25, :field_25, :raw, :o, 1},
      {26, :field_26, :raw, :o, 1},
      {27, :field_27, :raw, :o, 1},
      {28, :field_28, :raw, :o, 1},
      {29, :field_29, :raw, :o, 1},
      {30, :field_30, :raw, :o, 1},
      {31, :field_31, :raw, :o, 1},
      {32, :field_32, :raw, :o, 1},
      {33, :field_33, :raw, :o, 1},
      {34, :field_34, :raw, :o, 1},
      {35, :field_35, :raw, :o, 1},
      {36, :field_36, :raw, :o, 1},
      {37, :field_37, :raw, :o, 1},
      {38, :field_38, :raw, :o, 1}
    ]
end
