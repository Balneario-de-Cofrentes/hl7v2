defmodule HL7v2.Segment.PRC do
  @moduledoc """
  Pricing (PRC) segment -- HL7v2 v2.5.1.

  Contains pricing information for charges.

  18 fields per HL7 v2.5.1 specification. Fields 1-12 are typed,
  fields 13-18 use :raw.
  """

  use HL7v2.Segment,
    id: "PRC",
    fields: [
      {1, :primary_key_value, HL7v2.Type.CE, :r, 1},
      {2, :facility_id, HL7v2.Type.CE, :o, :unbounded},
      {3, :department, HL7v2.Type.CE, :o, :unbounded},
      {4, :valid_patient_classes, HL7v2.Type.IS, :o, :unbounded},
      {5, :price, HL7v2.Type.CP, :o, :unbounded},
      {6, :formula, HL7v2.Type.ST, :o, :unbounded},
      {7, :minimum_quantity, HL7v2.Type.NM, :o, 1},
      {8, :maximum_quantity, HL7v2.Type.NM, :o, 1},
      {9, :minimum_price, HL7v2.Type.MO, :o, 1},
      {10, :maximum_price, HL7v2.Type.MO, :o, 1},
      {11, :effective_start_date, HL7v2.Type.TS, :o, 1},
      {12, :effective_end_date, HL7v2.Type.TS, :o, 1},
      {13, :field_13, :raw, :o, 1},
      {14, :field_14, :raw, :o, 1},
      {15, :field_15, :raw, :o, 1},
      {16, :field_16, :raw, :o, 1},
      {17, :field_17, :raw, :o, 1},
      {18, :field_18, :raw, :o, 1}
    ]
end
