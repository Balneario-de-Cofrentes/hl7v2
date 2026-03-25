defmodule HL7v2.Segment.INV do
  @moduledoc """
  Inventory Detail (INV) segment -- HL7v2 v2.5.1.

  Contains inventory detail information for laboratory automation.
  20 fields per HL7 v2.5.1 specification. Fields 1-15 are typed,
  fields 16-20 use :raw.
  """

  use HL7v2.Segment,
    id: "INV",
    fields: [
      {1, :substance_identifier, HL7v2.Type.CE, :r, 1},
      {2, :substance_status, HL7v2.Type.CE, :r, :unbounded},
      {3, :substance_type, HL7v2.Type.CE, :o, 1},
      {4, :inventory_container_identifier, HL7v2.Type.CE, :o, 1},
      {5, :container_carrier_identifier, HL7v2.Type.CE, :o, 1},
      {6, :position_on_carrier, HL7v2.Type.CE, :o, 1},
      {7, :initial_quantity, HL7v2.Type.NM, :o, 1},
      {8, :current_quantity, HL7v2.Type.NM, :o, 1},
      {9, :available_quantity, HL7v2.Type.NM, :o, 1},
      {10, :consumption_quantity, HL7v2.Type.NM, :o, 1},
      {11, :quantity_units, HL7v2.Type.CE, :o, 1},
      {12, :expiration_date_time, HL7v2.Type.TS, :o, 1},
      {13, :first_used_date_time, HL7v2.Type.TS, :o, 1},
      {14, :on_board_stability_duration, HL7v2.Type.ST, :o, 1},
      {15, :on_board_stability_time, HL7v2.Type.TS, :o, 1},
      {16, :field_16, :raw, :o, 1},
      {17, :field_17, :raw, :o, 1},
      {18, :field_18, :raw, :o, 1},
      {19, :field_19, :raw, :o, 1},
      {20, :field_20, :raw, :o, 1}
    ]
end
