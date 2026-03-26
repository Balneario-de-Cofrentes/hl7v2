defmodule HL7v2.Segment.LDP do
  @moduledoc """
  Location Department (LDP) segment -- HL7v2 v2.5.1.

  Contains department information for a location.
  12 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "LDP",
    fields: [
      {1, :primary_key_value, HL7v2.Type.PL, :r, 1},
      {2, :location_department, HL7v2.Type.CE, :r, 1},
      {3, :location_service, HL7v2.Type.IS, :o, :unbounded},
      {4, :specialty_type, HL7v2.Type.CE, :o, :unbounded},
      {5, :valid_patient_classes, HL7v2.Type.IS, :o, :unbounded},
      {6, :active_inactive_flag, HL7v2.Type.ID, :o, 1},
      {7, :activation_date_ldp, HL7v2.Type.TS, :o, 1},
      {8, :inactivation_date_ldp, HL7v2.Type.TS, :o, 1},
      {9, :inactivated_reason, HL7v2.Type.ST, :o, 1},
      {10, :visiting_hours, HL7v2.Type.VH, :o, :unbounded},
      {11, :contact_phone, HL7v2.Type.XTN, :o, 1},
      {12, :location_cost_center, HL7v2.Type.CE, :o, 1}
    ]
end
