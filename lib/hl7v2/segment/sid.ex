defmodule HL7v2.Segment.SID do
  @moduledoc """
  Substance Identifier (SID) segment -- HL7v2 v2.5.1.

  Contains substance identifier information for laboratory automation.
  4 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "SID",
    fields: [
      {1, :application_method_identifier, HL7v2.Type.CE, :c, 1},
      {2, :substance_lot_number, HL7v2.Type.ST, :o, 1},
      {3, :substance_container_identifier, HL7v2.Type.ST, :o, 1},
      {4, :substance_manufacturer_identifier, HL7v2.Type.CE, :c, 1}
    ]
end
