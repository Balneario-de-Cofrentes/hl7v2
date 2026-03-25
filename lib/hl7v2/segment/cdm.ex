defmodule HL7v2.Segment.CDM do
  @moduledoc """
  Charge Description Master (CDM) segment — HL7v2 v2.5.1.

  Contains charge description master file detail information.

  13 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "CDM",
    fields: [
      {1, :primary_key_value, HL7v2.Type.CE, :r, 1},
      {2, :charge_code_alias, HL7v2.Type.CE, :o, :unbounded},
      {3, :charge_description_short, HL7v2.Type.ST, :r, 1},
      {4, :charge_description_long, HL7v2.Type.ST, :o, 1},
      {5, :description_override_indicator, HL7v2.Type.IS, :o, 1},
      {6, :exploding_charges, HL7v2.Type.CE, :o, :unbounded},
      {7, :procedure_code, HL7v2.Type.CE, :o, :unbounded},
      {8, :active_inactive_flag, HL7v2.Type.ID, :o, 1},
      {9, :inventory_number, HL7v2.Type.CE, :o, :unbounded},
      {10, :resource_load, HL7v2.Type.NM, :o, 1},
      {11, :contract_number, HL7v2.Type.CX, :o, :unbounded},
      {12, :contract_organization, HL7v2.Type.ST, :o, :unbounded},
      {13, :room_fee_indicator, HL7v2.Type.ID, :o, 1}
    ]
end
