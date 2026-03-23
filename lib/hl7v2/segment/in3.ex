defmodule HL7v2.Segment.IN3 do
  @moduledoc """
  Insurance Additional Information, Certification (IN3) segment — HL7v2 v2.5.1.

  Contains certification and pre-authorization details for insurance claims.
  28 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "IN3",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :r, 1},
      {2, :certification_number, HL7v2.Type.CX, :o, 1},
      {3, :certified_by, HL7v2.Type.XCN, :o, :unbounded},
      {4, :certification_required, HL7v2.Type.ID, :o, 1},
      {5, :penalty, HL7v2.Type.MO, :o, 1},
      {6, :certification_date_time, HL7v2.Type.TS, :o, 1},
      {7, :certification_modify_date_time, HL7v2.Type.TS, :o, 1},
      {8, :operator, HL7v2.Type.XCN, :o, :unbounded},
      {9, :certification_begin_date, HL7v2.Type.DT, :o, 1},
      {10, :certification_end_date, HL7v2.Type.DT, :o, 1},
      {11, :days, :raw, :o, 1},
      {12, :non_concur_code_description, HL7v2.Type.CE, :o, 1},
      {13, :non_concur_effective_date_time, HL7v2.Type.TS, :o, 1},
      {14, :physician_reviewer, HL7v2.Type.XCN, :o, :unbounded},
      {15, :certification_contact, HL7v2.Type.ST, :o, 1},
      {16, :certification_contact_phone_number, HL7v2.Type.XTN, :o, :unbounded},
      {17, :appeal_reason, HL7v2.Type.CE, :o, 1},
      {18, :certification_agency, HL7v2.Type.CE, :o, 1},
      {19, :certification_agency_phone_number, HL7v2.Type.XTN, :o, :unbounded},
      {20, :pre_certification_requirement, :raw, :o, :unbounded},
      {21, :case_manager, HL7v2.Type.ST, :o, 1},
      {22, :second_opinion_date, HL7v2.Type.DT, :o, 1},
      {23, :second_opinion_status, HL7v2.Type.IS, :o, 1},
      {24, :second_opinion_documentation_received, HL7v2.Type.IS, :o, :unbounded},
      {25, :second_opinion_physician, HL7v2.Type.XCN, :o, :unbounded},
      {26, :certification_type, HL7v2.Type.IS, :o, 1},
      {27, :certification_category, HL7v2.Type.IS, :o, 1},
      {28, :field_28, :raw, :o, 1}
    ]
end
