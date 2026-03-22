defmodule HL7v2.Segment.RGS do
  @moduledoc """
  Resource Group Segment (RGS) — HL7v2 v2.5.1.

  Marks the beginning of a resource group in scheduling messages (SIU, SQR).
  3 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "RGS",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :r, 1},
      {2, :segment_action_code, HL7v2.Type.ID, :c, 1},
      {3, :resource_group_id, HL7v2.Type.CE, :o, 1}
    ]
end
