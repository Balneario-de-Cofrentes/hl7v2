defmodule HL7v2.Segment.RQ1 do
  @moduledoc """
  Requisition Detail-1 (RQ1) segment -- HL7v2 v2.5.1.

  Contains requisition detail information.
  7 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "RQ1",
    fields: [
      {1, :anticipated_price, HL7v2.Type.ST, :o, 1},
      {2, :manufacturer_identifier, HL7v2.Type.CE, :o, 1},
      {3, :manufacturers_catalog, HL7v2.Type.ST, :o, 1},
      {4, :vendor_id, HL7v2.Type.CE, :o, 1},
      {5, :vendor_catalog, HL7v2.Type.ST, :o, 1},
      {6, :taxable, HL7v2.Type.ID, :o, 1},
      {7, :substitute_allowed, HL7v2.Type.ID, :o, 1}
    ]
end
