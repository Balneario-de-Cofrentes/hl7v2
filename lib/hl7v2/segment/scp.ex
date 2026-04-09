defmodule HL7v2.Segment.SCP do
  @moduledoc """
  Sterilizer Configuration (SCP) segment — HL7v2 v2.6+ (Chapter 17 Materials Management).

  Contains sterilizer/decontamination device configuration: number of
  devices, labor calculation type, date format, device identification,
  type, and lot control.

  8 fields per HL7 v2.6 specification. All fields are required.
  """

  use HL7v2.Segment,
    id: "SCP",
    fields: [
      {1, :number_of_decontamination_sterilization_devices, HL7v2.Type.NM, :r, 1},
      {2, :labor_calculation_type, HL7v2.Type.CWE, :r, 1},
      {3, :date_format, HL7v2.Type.CWE, :r, 1},
      {4, :device_number, HL7v2.Type.EI, :r, 1},
      {5, :device_name, HL7v2.Type.ST, :r, 1},
      {6, :device_model_name, HL7v2.Type.ST, :r, 1},
      {7, :device_type, HL7v2.Type.CWE, :r, 1},
      {8, :lot_control, HL7v2.Type.CWE, :r, 1}
    ]
end
