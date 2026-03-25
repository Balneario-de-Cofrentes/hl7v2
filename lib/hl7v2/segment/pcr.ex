defmodule HL7v2.Segment.PCR do
  @moduledoc """
  Possible Causal Relationship (PCR) segment -- HL7v2 v2.5.1.

  Contains possible causal relationship information for product experience.
  23 fields per HL7 v2.5.1 specification. Fields 1-15 are typed,
  fields 16-23 use :raw.
  """

  use HL7v2.Segment,
    id: "PCR",
    fields: [
      {1, :implicated_product, HL7v2.Type.CE, :r, 1},
      {2, :generic_product, HL7v2.Type.IS, :o, 1},
      {3, :product_class, HL7v2.Type.CE, :o, 1},
      {4, :total_duration_of_therapy, HL7v2.Type.CQ, :o, 1},
      {5, :product_manufacture_date, HL7v2.Type.TS, :o, 1},
      {6, :product_expiration_date, HL7v2.Type.TS, :o, 1},
      {7, :product_implantation_date, HL7v2.Type.TS, :o, 1},
      {8, :product_explantation_date, HL7v2.Type.TS, :o, 1},
      {9, :single_use_device, HL7v2.Type.IS, :o, 1},
      {10, :indication_for_product_use, HL7v2.Type.CE, :o, 1},
      {11, :product_problem, HL7v2.Type.IS, :o, 1},
      {12, :product_serial_lot_number, HL7v2.Type.ST, :o, :unbounded},
      {13, :product_available_for_inspection, HL7v2.Type.IS, :o, 1},
      {14, :product_evaluation_performed, HL7v2.Type.CE, :o, 1},
      {15, :product_evaluation_status, HL7v2.Type.CE, :o, 1},
      {16, :field_16, :raw, :o, 1},
      {17, :field_17, :raw, :o, 1},
      {18, :field_18, :raw, :o, 1},
      {19, :field_19, :raw, :o, 1},
      {20, :field_20, :raw, :o, 1},
      {21, :field_21, :raw, :o, 1},
      {22, :field_22, :raw, :o, 1},
      {23, :field_23, :raw, :o, 1}
    ]
end
