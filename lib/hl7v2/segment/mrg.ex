defmodule HL7v2.Segment.MRG do
  @moduledoc """
  Merge Patient Information (MRG) segment — HL7v2 v2.5.1.

  Carries the "prior" patient identifiers in merge operations (ADT^A39-A42).
  7 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "MRG",
    fields: [
      {1, :prior_patient_identifier_list, HL7v2.Type.CX, :r, :unbounded},
      {2, :prior_alternate_patient_id, HL7v2.Type.CX, :o, :unbounded},
      {3, :prior_patient_account_number, HL7v2.Type.CX, :o, 1},
      {4, :prior_patient_id, HL7v2.Type.CX, :o, 1},
      {5, :prior_visit_number, HL7v2.Type.CX, :o, 1},
      {6, :prior_alternate_visit_id, HL7v2.Type.CX, :o, 1},
      {7, :prior_patient_name, HL7v2.Type.XPN, :o, :unbounded}
    ]
end
