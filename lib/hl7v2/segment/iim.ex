defmodule HL7v2.Segment.IIM do
  @moduledoc """
  Inventory Item Master (IIM) segment -- HL7v2 v2.5.1.

  Contains inventory item master information for supply chain management.
  15 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "IIM",
    fields: [
      {1, :primary_key_value, HL7v2.Type.CWE, :r, 1},
      {2, :service_item_code, HL7v2.Type.CWE, :r, 1},
      {3, :inventory_lot_number, HL7v2.Type.ST, :o, 1},
      {4, :inventory_expiration_date, HL7v2.Type.TS, :o, 1},
      {5, :inventory_manufacturer_name, HL7v2.Type.CWE, :o, 1},
      {6, :inventory_location, HL7v2.Type.CWE, :o, 1},
      {7, :inventory_received_date, HL7v2.Type.TS, :o, 1},
      {8, :inventory_received_quantity, HL7v2.Type.NM, :o, 1},
      {9, :inventory_received_quantity_unit, HL7v2.Type.CWE, :o, 1},
      {10, :inventory_received_item_cost, HL7v2.Type.MO, :o, 1},
      {11, :inventory_on_hand_date, HL7v2.Type.TS, :o, 1},
      {12, :inventory_on_hand_quantity, HL7v2.Type.NM, :o, 1},
      {13, :inventory_on_hand_quantity_unit, HL7v2.Type.CWE, :o, 1},
      {14, :procedure_code, HL7v2.Type.CE, :o, 1},
      {15, :procedure_code_modifier, HL7v2.Type.CE, :o, :unbounded}
    ]
end
