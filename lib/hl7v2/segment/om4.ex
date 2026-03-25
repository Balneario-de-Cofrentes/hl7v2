defmodule HL7v2.Segment.OM4 do
  @moduledoc """
  Observations that Require Specimens (OM4) segment -- HL7v2 v2.5.1.

  Contains attributes of observations that require specimens.
  14 fields per HL7 v2.5.1 specification. Fields 1-10 are typed,
  fields 11-14 use :raw.
  """

  use HL7v2.Segment,
    id: "OM4",
    fields: [
      {1, :sequence_number, HL7v2.Type.NM, :o, 1},
      {2, :derived_specimen, HL7v2.Type.ID, :o, 1},
      {3, :container_description, HL7v2.Type.TX, :o, 1},
      {4, :container_volume, HL7v2.Type.NM, :o, 1},
      {5, :container_units, HL7v2.Type.CE, :o, 1},
      {6, :specimen, HL7v2.Type.CE, :o, 1},
      {7, :additive, HL7v2.Type.CWE, :o, 1},
      {8, :preparation, HL7v2.Type.TX, :o, 1},
      {9, :special_handling_requirements, HL7v2.Type.TX, :o, 1},
      {10, :normal_collection_volume, HL7v2.Type.CQ, :o, 1},
      {11, :field_11, :raw, :o, 1},
      {12, :field_12, :raw, :o, 1},
      {13, :field_13, :raw, :o, 1},
      {14, :field_14, :raw, :o, 1}
    ]
end
