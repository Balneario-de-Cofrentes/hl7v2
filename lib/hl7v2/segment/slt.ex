defmodule HL7v2.Segment.SLT do
  @moduledoc """
  Sterilization Lot (SLT) segment — HL7v2 v2.6+ (Chapter 17 Materials Management).

  Identifies a sterilization lot and the device that processed it.
  Complements SCP (Sterilizer Configuration) and SDD (Sterilization
  Device Data) by tying a batch of items to a specific sterilizer run.

  5 fields per HL7 v2.6 specification.
  """

  use HL7v2.Segment,
    id: "SLT",
    fields: [
      {1, :device_number, HL7v2.Type.EI, :r, 1},
      {2, :device_name, HL7v2.Type.ST, :o, 1},
      {3, :lot_number, HL7v2.Type.EI, :r, 1},
      {4, :item_identifier, HL7v2.Type.EI, :o, 1},
      {5, :bar_code, HL7v2.Type.ST, :o, 1}
    ]
end
