defmodule HL7v2.Segment.PEO do
  @moduledoc """
  Product Experience Observation (PEO) segment -- HL7v2 v2.5.1.

  Contains product experience observation information.
  25 fields per HL7 v2.5.1 specification. Fields 1-15 are typed,
  fields 16-25 use :raw.
  """

  use HL7v2.Segment,
    id: "PEO",
    fields: [
      {1, :event_identifiers_used, HL7v2.Type.CE, :o, :unbounded},
      {2, :event_symptom_diagnosis_code, HL7v2.Type.CE, :o, :unbounded},
      {3, :event_onset_date_time, HL7v2.Type.TS, :r, 1},
      {4, :event_exacerbation_date_time, HL7v2.Type.TS, :o, 1},
      {5, :event_improved_date_time, HL7v2.Type.TS, :o, 1},
      {6, :event_ended_data_time, HL7v2.Type.TS, :o, 1},
      {7, :event_location_occurred_address, HL7v2.Type.XAD, :o, :unbounded},
      {8, :event_qualification, HL7v2.Type.ID, :o, :unbounded},
      {9, :event_serious, HL7v2.Type.ID, :o, 1},
      {10, :event_expected, HL7v2.Type.ID, :o, 1},
      {11, :event_outcome, HL7v2.Type.ID, :o, :unbounded},
      {12, :patient_outcome, HL7v2.Type.ID, :o, 1},
      {13, :event_description_from_others, HL7v2.Type.FT, :o, :unbounded},
      {14, :event_from_original_reporter, HL7v2.Type.FT, :o, :unbounded},
      {15, :event_description_from_patient, HL7v2.Type.FT, :o, :unbounded},
      {16, :field_16, :raw, :o, 1},
      {17, :field_17, :raw, :o, 1},
      {18, :field_18, :raw, :o, 1},
      {19, :field_19, :raw, :o, 1},
      {20, :field_20, :raw, :o, 1},
      {21, :field_21, :raw, :o, 1},
      {22, :field_22, :raw, :o, 1},
      {23, :field_23, :raw, :o, 1},
      {24, :field_24, :raw, :o, 1},
      {25, :field_25, :raw, :o, 1}
    ]
end
