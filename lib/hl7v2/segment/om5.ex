defmodule HL7v2.Segment.OM5 do
  @moduledoc """
  Observation Batteries (OM5) segment -- HL7v2 v2.5.1.

  Contains attributes of observations that are batteries (sets).
  3 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "OM5",
    fields: [
      {1, :sequence_number, HL7v2.Type.NM, :o, 1},
      {2, :test_observations_included_within_an_ordered_test_battery, HL7v2.Type.CE, :o,
       :unbounded},
      {3, :observation_id_suffixes, HL7v2.Type.ST, :o, 1}
    ]
end
