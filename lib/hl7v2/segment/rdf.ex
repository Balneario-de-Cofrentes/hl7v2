defmodule HL7v2.Segment.RDF do
  @moduledoc """
  Table Row Definition (RDF) segment -- HL7v2 v2.5.1.

  Contains table row definition for tabular responses.
  2 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "RDF",
    fields: [
      {1, :number_of_columns_per_row, HL7v2.Type.NM, :r, 1},
      {2, :column_description, HL7v2.Type.RCD, :r, :unbounded}
    ]
end
