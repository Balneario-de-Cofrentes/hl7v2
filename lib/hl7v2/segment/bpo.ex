defmodule HL7v2.Segment.BPO do
  @moduledoc """
  Blood Product Order (BPO) segment -- HL7v2 v2.5.1.

  Contains blood product order information.
  14 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "BPO",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :r, 1},
      {2, :bp_universal_service_id, HL7v2.Type.CWE, :r, 1},
      {3, :bp_processing_requirements, HL7v2.Type.CWE, :o, :unbounded},
      {4, :bp_quantity, HL7v2.Type.NM, :r, 1},
      {5, :bp_amount, HL7v2.Type.NM, :o, 1},
      {6, :bp_units, HL7v2.Type.CE, :o, 1},
      {7, :bp_intended_use_date_time, HL7v2.Type.TS, :o, 1},
      {8, :bp_intended_dispense_from_location, HL7v2.Type.PL, :o, 1},
      {9, :bp_intended_dispense_from_address, HL7v2.Type.XAD, :o, 1},
      {10, :bp_requested_dispense_date_time, HL7v2.Type.TS, :o, 1},
      {11, :bp_requested_dispense_to_location, HL7v2.Type.PL, :o, 1},
      {12, :bp_requested_dispense_to_address, HL7v2.Type.XAD, :o, 1},
      {13, :bp_indication_for_use, HL7v2.Type.CWE, :o, :unbounded},
      {14, :bp_informed_consent_indicator, HL7v2.Type.ID, :o, 1}
    ]
end
