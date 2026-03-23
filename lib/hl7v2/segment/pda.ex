defmodule HL7v2.Segment.PDA do
  @moduledoc """
  Patient Death and Autopsy (PDA) segment — HL7v2 v2.5.1.

  Contains information about a patient's death, certification, and
  autopsy details.

  9 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "PDA",
    fields: [
      {1, :death_cause_code, HL7v2.Type.CE, :o, :unbounded},
      {2, :death_location, HL7v2.Type.PL, :o, 1},
      {3, :death_certified_indicator, HL7v2.Type.ID, :o, 1},
      {4, :death_certificate_signed_date_time, HL7v2.Type.TS, :o, 1},
      {5, :death_certified_by, HL7v2.Type.XCN, :o, 1},
      {6, :autopsy_indicator, HL7v2.Type.ID, :o, 1},
      {7, :autopsy_start_and_end_date_time, HL7v2.Type.DR, :o, 1},
      {8, :autopsy_performed_by, HL7v2.Type.XCN, :o, 1},
      {9, :coroner_indicator, HL7v2.Type.ID, :o, 1}
    ]
end
