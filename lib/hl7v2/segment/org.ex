defmodule HL7v2.Segment.ORG do
  @moduledoc """
  Practitioner Organization Unit (ORG) segment -- HL7v2 v2.5.1.

  Contains practitioner organization unit information.
  12 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "ORG",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :r, 1},
      {2, :organization_unit_code, HL7v2.Type.CE, :o, 1},
      {3, :organization_unit_type_code, HL7v2.Type.CE, :o, 1},
      {4, :primary_org_unit_indicator, HL7v2.Type.ID, :o, 1},
      {5, :practitioner_org_unit_identifier, HL7v2.Type.CX, :o, 1},
      {6, :health_care_provider_type_code, HL7v2.Type.CE, :o, 1},
      {7, :health_care_provider_classification_code, HL7v2.Type.CE, :o, 1},
      {8, :health_care_provider_area_of_specialization_code, HL7v2.Type.CE, :o, 1},
      {9, :effective_date_range, HL7v2.Type.DR, :o, 1},
      {10, :employment_status_code, HL7v2.Type.CE, :o, 1},
      {11, :board_approval_indicator, HL7v2.Type.ID, :o, 1},
      {12, :primary_care_physician_indicator, HL7v2.Type.ID, :o, 1}
    ]
end
