defmodule HL7v2.Segment.SDD do
  @moduledoc """
  Sterilization Device Data (SDD) segment -- HL7v2 v2.5.1.

  Contains sterilization device data.
  7 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "SDD",
    fields: [
      {1, :lot_number, HL7v2.Type.EI, :o, 1},
      {2, :device_number, HL7v2.Type.EI, :o, 1},
      {3, :device_name, HL7v2.Type.ST, :o, 1},
      {4, :device_data_state, HL7v2.Type.IS, :o, 1},
      {5, :load_status, HL7v2.Type.IS, :o, 1},
      {6, :control_code, HL7v2.Type.NM, :o, 1},
      {7, :operator_name, HL7v2.Type.ST, :o, 1}
    ]
end
