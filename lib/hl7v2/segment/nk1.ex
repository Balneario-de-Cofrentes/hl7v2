defmodule HL7v2.Segment.NK1 do
  @moduledoc """
  Next of Kin / Associated Parties (NK1) segment — HL7v2 v2.5.1.

  Identifies related persons. 39 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "NK1",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :r, 1},
      {2, :nk_name, HL7v2.Type.XPN, :o, :unbounded},
      {3, :relationship, HL7v2.Type.CE, :o, 1},
      {4, :address, HL7v2.Type.XAD, :o, :unbounded},
      {5, :phone_number, HL7v2.Type.XTN, :o, :unbounded},
      {6, :business_phone_number, HL7v2.Type.XTN, :o, :unbounded},
      {7, :contact_role, HL7v2.Type.CE, :o, 1},
      {8, :start_date, HL7v2.Type.DT, :o, 1},
      {9, :end_date, HL7v2.Type.DT, :o, 1},
      {10, :next_of_kin_job_title, HL7v2.Type.ST, :o, 1},
      {11, :next_of_kin_job_code_class, HL7v2.Type.JCC, :o, 1},
      {12, :next_of_kin_employee_number, HL7v2.Type.CX, :o, 1},
      {13, :organization_name, HL7v2.Type.XON, :o, :unbounded},
      {14, :marital_status, HL7v2.Type.CE, :o, 1},
      {15, :administrative_sex, HL7v2.Type.IS, :o, 1},
      {16, :date_time_of_birth, HL7v2.Type.TS, :o, 1},
      {17, :living_dependency, HL7v2.Type.IS, :o, :unbounded},
      {18, :ambulatory_status, HL7v2.Type.IS, :o, :unbounded},
      {19, :citizenship, HL7v2.Type.CE, :o, :unbounded},
      {20, :primary_language, HL7v2.Type.CE, :o, 1},
      {21, :living_arrangement, HL7v2.Type.IS, :o, 1},
      {22, :publicity_code, HL7v2.Type.CE, :o, 1},
      {23, :protection_indicator, HL7v2.Type.ID, :o, 1},
      {24, :student_indicator, HL7v2.Type.IS, :o, 1},
      {25, :religion, HL7v2.Type.CE, :o, 1},
      {26, :mothers_maiden_name, HL7v2.Type.XPN, :o, :unbounded},
      {27, :nationality, HL7v2.Type.CE, :o, 1},
      {28, :ethnic_group, HL7v2.Type.CE, :o, :unbounded},
      {29, :contact_reason, HL7v2.Type.CE, :o, :unbounded},
      {30, :contact_persons_name, HL7v2.Type.XPN, :o, :unbounded},
      {31, :contact_persons_telephone_number, HL7v2.Type.XTN, :o, :unbounded},
      {32, :contact_persons_address, HL7v2.Type.XAD, :o, :unbounded},
      {33, :next_of_kin_identifiers, HL7v2.Type.CX, :o, :unbounded},
      {34, :job_status, HL7v2.Type.IS, :o, 1},
      {35, :race, HL7v2.Type.CE, :o, :unbounded},
      {36, :handicap, HL7v2.Type.IS, :o, 1},
      {37, :contact_person_social_security_number, HL7v2.Type.ST, :o, 1},
      {38, :next_of_kin_birth_place, HL7v2.Type.ST, :o, 1},
      {39, :vip_indicator, HL7v2.Type.IS, :o, 1}
    ]
end
