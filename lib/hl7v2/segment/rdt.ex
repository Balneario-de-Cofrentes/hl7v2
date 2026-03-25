defmodule HL7v2.Segment.RDT do
  @moduledoc """
  Table Row Data (RDT) segment -- HL7v2 v2.5.1.

  Contains table row data for tabular responses.
  1 field per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "RDT",
    fields: [
      {1, :column_value, :raw, :r, 1}
    ]
end
