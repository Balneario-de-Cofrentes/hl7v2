defmodule HL7v2.Segment.SPM do
  @moduledoc """
  Specimen (SPM) segment — HL7v2 v2.5.1.

  Contains specimen-related information for laboratory orders. Replaces
  the OBR-15 specimen source field with a richer, structured model.

  30 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "SPM",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :o, 1},
      {2, :specimen_id, HL7v2.Type.EIP, :o, 1},
      {3, :specimen_parent_ids, HL7v2.Type.EIP, :o, :unbounded},
      {4, :specimen_type, HL7v2.Type.CWE, :r, 1},
      {5, :specimen_type_modifier, HL7v2.Type.CWE, :o, :unbounded},
      {6, :specimen_additives, HL7v2.Type.CWE, :o, :unbounded},
      {7, :specimen_collection_method, HL7v2.Type.CWE, :o, 1},
      {8, :specimen_source_site, HL7v2.Type.CWE, :o, 1},
      {9, :specimen_source_site_modifier, HL7v2.Type.CWE, :o, :unbounded},
      {10, :specimen_collection_site, HL7v2.Type.CWE, :o, 1},
      {11, :specimen_role, HL7v2.Type.CWE, :o, :unbounded},
      {12, :specimen_collection_amount, HL7v2.Type.CQ, :o, 1},
      {13, :grouped_specimen_count, HL7v2.Type.NM, :o, 1},
      {14, :specimen_description, HL7v2.Type.ST, :o, :unbounded},
      {15, :specimen_handling_code, HL7v2.Type.CWE, :o, :unbounded},
      {16, :specimen_risk_code, HL7v2.Type.CWE, :o, :unbounded},
      {17, :specimen_collection_date_time, HL7v2.Type.DR, :o, 1},
      {18, :specimen_received_date_time, HL7v2.Type.TS, :o, 1},
      {19, :specimen_expiration_date_time, HL7v2.Type.TS, :o, 1},
      {20, :specimen_availability, HL7v2.Type.ID, :o, 1},
      {21, :specimen_reject_reason, HL7v2.Type.CWE, :o, :unbounded},
      {22, :specimen_quality, HL7v2.Type.CWE, :o, 1},
      {23, :specimen_appropriateness, HL7v2.Type.CWE, :o, 1},
      {24, :specimen_condition, HL7v2.Type.CWE, :o, :unbounded},
      {25, :specimen_current_quantity, HL7v2.Type.CQ, :o, 1},
      {26, :number_of_specimen_containers, HL7v2.Type.NM, :o, 1},
      {27, :container_type, HL7v2.Type.CWE, :o, 1},
      {28, :container_condition, HL7v2.Type.CWE, :o, 1},
      {29, :specimen_child_role, HL7v2.Type.CWE, :o, 1},
      {30, :field_30, HL7v2.Type.CWE, :o, 1}
    ]
end
