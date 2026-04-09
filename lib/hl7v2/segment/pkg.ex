defmodule HL7v2.Segment.PKG do
  @moduledoc """
  Item Packaging (PKG) segment — HL7v2 v2.6+ (Chapter 17 Materials Management).

  Describes packaging unit definitions and pricing for a material item.
  One PKG row per packaging level (e.g., each, box, case, pallet).

  7 fields per HL7 v2.6 specification.
  """

  use HL7v2.Segment,
    id: "PKG",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :r, 1},
      {2, :packaging_units_code, HL7v2.Type.CWE, :r, 1},
      {3, :default_order_unit_of_measure_indicator, HL7v2.Type.ID, :o, 1},
      {4, :package_quantity, HL7v2.Type.NM, :o, 1},
      {5, :price, HL7v2.Type.CP, :o, 1},
      {6, :future_item_price, HL7v2.Type.CP, :o, 1},
      {7, :future_item_price_effective_date, HL7v2.Type.DTM, :o, 1}
    ]
end
