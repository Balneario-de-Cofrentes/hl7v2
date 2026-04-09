defmodule HL7v2.Segment.IVT do
  @moduledoc """
  Material Location (IVT) segment — HL7v2 v2.6+ (Chapter 17 Materials Management).

  Describes a physical location where inventory items are stored. Used with
  ITM to define per-location stocking policies, par levels, reorder points,
  and packaging.

  26 fields per HL7 v2.6 specification.
  """

  use HL7v2.Segment,
    id: "IVT",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :r, 1},
      {2, :inventory_location_identifier, HL7v2.Type.EI, :r, 1},
      {3, :inventory_location_name, HL7v2.Type.ST, :o, 1},
      {4, :source_location_identifier, HL7v2.Type.EI, :o, 1},
      {5, :source_location_name, HL7v2.Type.ST, :o, 1},
      {6, :item_status, HL7v2.Type.CWE, :o, 1},
      {7, :bin_location_identifier, HL7v2.Type.EI, :o, :unbounded},
      {8, :order_packaging, HL7v2.Type.CWE, :o, 1},
      {9, :issue_packaging, HL7v2.Type.CWE, :o, 1},
      {10, :default_inventory_asset_account, HL7v2.Type.EI, :o, 1},
      {11, :patient_chargeable_indicator, HL7v2.Type.ID, :o, 1},
      {12, :transaction_code, HL7v2.Type.CWE, :o, 1},
      {13, :transaction_amount_unit, HL7v2.Type.CP, :o, 1},
      {14, :item_importance_code, HL7v2.Type.CWE, :o, 1},
      {15, :stocked_item_indicator, HL7v2.Type.ID, :o, 1},
      {16, :consignment_item_indicator, HL7v2.Type.ID, :o, 1},
      {17, :reusable_item_indicator, HL7v2.Type.ID, :o, 1},
      {18, :reusable_cost, HL7v2.Type.CP, :o, 1},
      {19, :substitute_item_identifier, HL7v2.Type.EI, :o, :unbounded},
      {20, :latex_free_substitute_item_identifier, HL7v2.Type.EI, :o, 1},
      {21, :recommended_reorder_theory, HL7v2.Type.CWE, :o, 1},
      {22, :recommended_safety_stock_days, HL7v2.Type.NM, :o, 1},
      {23, :recommended_maximum_days_inventory, HL7v2.Type.NM, :o, 1},
      {24, :recommended_order_point, HL7v2.Type.NM, :o, 1},
      {25, :recommended_order_amount, HL7v2.Type.NM, :o, 1},
      {26, :operating_room_par_level_indicator, HL7v2.Type.ID, :o, 1}
    ]
end
