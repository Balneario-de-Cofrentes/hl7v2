defmodule HL7v2.Segment.OM7 do
  @moduledoc """
  Additional Basic Attributes (OM7) segment -- HL7v2 v2.5.1.

  Contains additional basic attributes for an observation/service.
  24 fields per HL7 v2.5.1 specification. Fields 1-15 are typed,
  fields 16-24 use :raw.
  """

  use HL7v2.Segment,
    id: "OM7",
    fields: [
      {1, :sequence_number, HL7v2.Type.NM, :r, 1},
      {2, :universal_service_identifier, HL7v2.Type.CE, :r, 1},
      {3, :category_identifier, HL7v2.Type.CE, :o, :unbounded},
      {4, :category_description, HL7v2.Type.TX, :o, 1},
      {5, :category_synonym, HL7v2.Type.ST, :o, :unbounded},
      {6, :effective_test_service_start_date_time, HL7v2.Type.TS, :o, 1},
      {7, :effective_test_service_end_date_time, HL7v2.Type.TS, :o, 1},
      {8, :test_service_default_duration_quantity, HL7v2.Type.NM, :o, 1},
      {9, :test_service_default_duration_units, HL7v2.Type.CE, :o, 1},
      {10, :test_service_default_frequency, HL7v2.Type.IS, :o, 1},
      {11, :consent_indicator, HL7v2.Type.ID, :o, 1},
      {12, :consent_identifier, HL7v2.Type.CE, :o, 1},
      {13, :consent_effective_start_date_time, HL7v2.Type.TS, :o, 1},
      {14, :consent_effective_end_date_time, HL7v2.Type.TS, :o, 1},
      {15, :consent_interval_quantity, HL7v2.Type.NM, :o, 1},
      {16, :field_16, :raw, :o, 1},
      {17, :field_17, :raw, :o, 1},
      {18, :field_18, :raw, :o, 1},
      {19, :field_19, :raw, :o, 1},
      {20, :field_20, :raw, :o, 1},
      {21, :field_21, :raw, :o, 1},
      {22, :field_22, :raw, :o, 1},
      {23, :field_23, :raw, :o, 1},
      {24, :field_24, :raw, :o, 1}
    ]
end
