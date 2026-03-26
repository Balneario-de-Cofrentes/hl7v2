defmodule HL7v2.Segment.PDC do
  @moduledoc """
  Product Detail Country (PDC) segment -- HL7v2 v2.5.1.

  Contains product detail country information for product experience.
  15 fields per HL7 v2.5.1 specification.
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
      {11, :marketing_approval_id, HL7v2.Type.ST, :o, 1},
      {12, :labeled_shelf_life, HL7v2.Type.CQ, :o, 1},
      {13, :expected_shelf_life, HL7v2.Type.CQ, :o, 1},
      {14, :date_first_marketed, HL7v2.Type.TS, :o, 1},
      {15, :date_last_marketed, HL7v2.Type.TS, :o, 1}
    ]
end
