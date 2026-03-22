defmodule HL7v2.Segment.SCH do
  @moduledoc """
  Scheduling Activity Information (SCH) segment — HL7v2 v2.5.1.

  Contains scheduling request information.
  27 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "SCH",
    fields: [
      {1, :placer_appointment_id, HL7v2.Type.EI, :c, 1},
      {2, :filler_appointment_id, HL7v2.Type.EI, :c, 1},
      {3, :occurrence_number, HL7v2.Type.NM, :c, 1},
      {4, :placer_group_number, HL7v2.Type.EI, :o, 1},
      {5, :schedule_id, HL7v2.Type.CE, :o, 1},
      {6, :event_reason, HL7v2.Type.CE, :r, 1},
      {7, :appointment_reason, HL7v2.Type.CE, :o, 1},
      {8, :appointment_type, HL7v2.Type.CE, :o, 1},
      {9, :appointment_duration, HL7v2.Type.NM, :o, 1},
      {10, :appointment_duration_units, HL7v2.Type.CE, :o, 1},
      {11, :appointment_timing_quantity, :raw, :b, :unbounded},
      {12, :placer_contact_person, HL7v2.Type.XCN, :o, :unbounded},
      {13, :placer_contact_phone_number, HL7v2.Type.XTN, :o, 1},
      {14, :placer_contact_address, HL7v2.Type.XAD, :o, :unbounded},
      {15, :placer_contact_location, HL7v2.Type.PL, :o, 1},
      {16, :filler_contact_person, HL7v2.Type.XCN, :r, :unbounded},
      {17, :filler_contact_phone_number, HL7v2.Type.XTN, :o, 1},
      {18, :filler_contact_address, HL7v2.Type.XAD, :o, :unbounded},
      {19, :filler_contact_location, HL7v2.Type.PL, :o, 1},
      {20, :entered_by_person, HL7v2.Type.XCN, :r, :unbounded},
      {21, :entered_by_phone_number, HL7v2.Type.XTN, :o, :unbounded},
      {22, :entered_by_location, HL7v2.Type.PL, :o, 1},
      {23, :parent_placer_appointment_id, HL7v2.Type.EI, :o, 1},
      {24, :parent_filler_appointment_id, HL7v2.Type.EI, :o, 1},
      {25, :filler_status_code, HL7v2.Type.CE, :c, 1},
      {26, :placer_order_number, HL7v2.Type.EI, :o, :unbounded},
      {27, :filler_order_number, HL7v2.Type.EI, :o, :unbounded}
    ]
end
