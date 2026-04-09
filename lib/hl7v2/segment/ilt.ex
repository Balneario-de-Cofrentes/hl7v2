defmodule HL7v2.Segment.ILT do
  @moduledoc """
  Material Lot (ILT) segment — HL7v2 v2.6+ (Chapter 17 Materials Management).

  Lot-specific tracking detail for inventory items. Complements ITM by
  capturing per-lot expiration dates, received-and-on-hand quantities, and
  lot-level cost data.

  10 fields per HL7 v2.6 specification.
  """

  use HL7v2.Segment,
    id: "ILT",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :r, 1},
      {2, :inventory_lot_number, HL7v2.Type.ST, :o, 1},
      {3, :inventory_expiration_date, HL7v2.Type.DTM, :o, 1},
      {4, :inventory_received_date, HL7v2.Type.DTM, :o, 1},
      {5, :inventory_received_quantity, HL7v2.Type.NM, :o, 1},
      {6, :inventory_received_quantity_unit, HL7v2.Type.CWE, :o, 1},
      {7, :inventory_received_item_cost, HL7v2.Type.MO, :o, 1},
      {8, :inventory_on_hand_date, HL7v2.Type.DTM, :o, 1},
      {9, :inventory_on_hand_quantity, HL7v2.Type.NM, :o, 1},
      {10, :inventory_on_hand_quantity_unit, HL7v2.Type.CWE, :o, 1}
    ]
end
