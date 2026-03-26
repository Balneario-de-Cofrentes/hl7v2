defmodule HL7v2.Segment.ARQ do
  @moduledoc """
  Appointment Request (ARQ) segment -- HL7v2 v2.5.1.

  Contains appointment request information for scheduling.
  25 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "ARQ",
    fields: [
      {1, :placer_appointment_id, HL7v2.Type.EI, :r, 1},
      {2, :filler_appointment_id, HL7v2.Type.EI, :c, 1},
      {3, :occurrence_number, HL7v2.Type.NM, :o, 1},
      {4, :placer_group_number, HL7v2.Type.EI, :o, 1},
      {5, :schedule_id, HL7v2.Type.CE, :o, 1},
      {6, :request_event_reason, HL7v2.Type.CE, :o, 1},
      {7, :appointment_reason, HL7v2.Type.CE, :o, 1},
      {8, :appointment_type, HL7v2.Type.CE, :o, 1},
      {9, :appointment_duration, HL7v2.Type.NM, :o, 1},
      {10, :appointment_duration_units, HL7v2.Type.CE, :o, 1},
      {11, :requested_start_date_time_range, HL7v2.Type.DR, :o, :unbounded},
      {12, :priority_arq, HL7v2.Type.ST, :o, 1},
      {13, :repeating_interval, HL7v2.Type.RI, :o, 1},
      {14, :repeating_interval_duration, HL7v2.Type.ST, :o, 1},
      {15, :placer_contact_person, HL7v2.Type.XCN, :r, :unbounded},
      {16, :placer_contact_phone_number, HL7v2.Type.XTN, :o, :unbounded},
      {17, :placer_contact_address, HL7v2.Type.XAD, :o, :unbounded},
      {18, :placer_contact_location, HL7v2.Type.PL, :o, 1},
      {19, :entered_by_person, HL7v2.Type.XCN, :r, :unbounded},
      {20, :entered_by_phone_number, HL7v2.Type.XTN, :o, :unbounded},
      {21, :entered_by_location, HL7v2.Type.PL, :o, 1},
      {22, :parent_placer_appointment_id, HL7v2.Type.EI, :o, 1},
      {23, :parent_filler_appointment_id, HL7v2.Type.EI, :o, 1},
      {24, :placer_order_number, HL7v2.Type.EI, :o, :unbounded},
      {25, :filler_order_number, HL7v2.Type.EI, :o, :unbounded}
    ]
end
