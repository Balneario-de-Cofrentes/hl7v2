defmodule HL7v2.Segment.PDC do
  @moduledoc """
  Product Detail Country (PDC) segment -- HL7v2 v2.5.1.

  Contains product detail country information for product experience.
  15 fields per HL7 v2.5.1 specification. Fields 1-10 are typed,
  fields 11-15 use :raw.
  """

  use HL7v2.Segment,
    id: "PDC",
    fields: [
      {1, :manufacturer_distributor, HL7v2.Type.XON, :r, :unbounded},
      {2, :country, HL7v2.Type.CE, :r, 1},
      {3, :brand_name, HL7v2.Type.ST, :r, 1},
      {4, :device_family_name, HL7v2.Type.ST, :o, 1},
      {5, :generic_name, HL7v2.Type.CE, :o, 1},
      {6, :model_identifier, HL7v2.Type.ST, :o, :unbounded},
      {7, :catalogue_identifier, HL7v2.Type.ST, :o, 1},
      {8, :other_identifier, HL7v2.Type.ST, :o, :unbounded},
      {9, :product_code, HL7v2.Type.CE, :o, 1},
      {10, :marketing_basis, HL7v2.Type.ID, :o, 1},
      {11, :field_11, :raw, :o, 1},
      {12, :field_12, :raw, :o, 1},
      {13, :field_13, :raw, :o, 1},
      {14, :field_14, :raw, :o, 1},
      {15, :field_15, :raw, :o, 1}
    ]
end
