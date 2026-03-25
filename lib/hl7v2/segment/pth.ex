defmodule HL7v2.Segment.PTH do
  @moduledoc """
  Pathway (PTH) segment -- HL7v2 v2.5.1.

  Contains pathway (clinical pathway/care plan) information.
  6 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "PTH",
    fields: [
      {1, :action_code, HL7v2.Type.ID, :r, 1},
      {2, :pathway_id, HL7v2.Type.CE, :r, 1},
      {3, :pathway_instance_id, HL7v2.Type.EI, :r, 1},
      {4, :pathway_established_date_time, HL7v2.Type.TS, :r, 1},
      {5, :pathway_life_cycle_status, HL7v2.Type.CE, :o, 1},
      {6, :change_pathway_life_cycle_status_date_time, HL7v2.Type.TS, :o, 1}
    ]
end
