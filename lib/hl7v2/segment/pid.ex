defmodule HL7v2.Segment.PID do
  @moduledoc """
  Patient Identification (PID) segment — HL7v2 v2.5.1.

  Primary patient demographics segment. 39 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "PID",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :o, 1},
      {2, :patient_id, HL7v2.Type.CX, :b, 1},
      {3, :patient_identifier_list, HL7v2.Type.CX, :r, :unbounded},
      {4, :alternate_patient_id, HL7v2.Type.CX, :b, :unbounded},
      {5, :patient_name, HL7v2.Type.XPN, :r, :unbounded},
      {6, :mothers_maiden_name, HL7v2.Type.XPN, :o, :unbounded},
      {7, :date_time_of_birth, HL7v2.Type.TS, :o, 1},
      {8, :administrative_sex, HL7v2.Type.IS, :o, 1},
      {9, :patient_alias, HL7v2.Type.XPN, :b, :unbounded},
      {10, :race, HL7v2.Type.CE, :o, :unbounded},
      {11, :patient_address, HL7v2.Type.XAD, :o, :unbounded},
      {12, :county_code, HL7v2.Type.IS, :b, 1},
      {13, :phone_number_home, HL7v2.Type.XTN, :o, :unbounded},
      {14, :phone_number_business, HL7v2.Type.XTN, :o, :unbounded},
      {15, :primary_language, HL7v2.Type.CE, :o, 1},
      {16, :marital_status, HL7v2.Type.CE, :o, 1},
      {17, :religion, HL7v2.Type.CE, :o, 1},
      {18, :patient_account_number, HL7v2.Type.CX, :o, 1},
      {19, :ssn_number, HL7v2.Type.ST, :b, 1},
      {20, :drivers_license_number, :raw, :b, 1},
      {21, :mothers_identifier, HL7v2.Type.CX, :o, :unbounded},
      {22, :ethnic_group, HL7v2.Type.CE, :o, :unbounded},
      {23, :birth_place, HL7v2.Type.ST, :o, 1},
      {24, :multiple_birth_indicator, HL7v2.Type.ID, :o, 1},
      {25, :birth_order, HL7v2.Type.NM, :o, 1},
      {26, :citizenship, HL7v2.Type.CE, :o, :unbounded},
      {27, :veterans_military_status, HL7v2.Type.CE, :o, 1},
      {28, :nationality, HL7v2.Type.CE, :b, 1},
      {29, :patient_death_date_and_time, HL7v2.Type.TS, :o, 1},
      {30, :patient_death_indicator, HL7v2.Type.ID, :o, 1},
      {31, :identity_unknown_indicator, HL7v2.Type.ID, :o, 1},
      {32, :identity_reliability_code, HL7v2.Type.IS, :o, :unbounded},
      {33, :last_update_date_time, HL7v2.Type.TS, :o, 1},
      {34, :last_update_facility, HL7v2.Type.HD, :o, 1},
      {35, :species_code, HL7v2.Type.CE, :c, 1},
      {36, :breed_code, HL7v2.Type.CE, :c, 1},
      {37, :strain, HL7v2.Type.ST, :o, 1},
      {38, :production_class_code, HL7v2.Type.CE, :o, 1},
      {39, :tribal_citizenship, HL7v2.Type.CWE, :o, :unbounded}
    ]
end
