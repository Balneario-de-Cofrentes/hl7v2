defmodule HL7v2.Segment.QPD do
  @moduledoc """
  Query Parameter Definition (QPD) segment -- HL7v2 v2.5.1.

  Contains query parameter definitions. Fields beyond 2 are query-specific
  and carried as :raw.
  3 fields per HL7 v2.5.1 specification (minimum).
  """

  use HL7v2.Segment,
    id: "QPD",
    fields: [
      {1, :message_query_name, HL7v2.Type.CE, :r, 1},
      {2, :query_tag, HL7v2.Type.ST, :r, 1},
      {3, :user_parameters_in_successive_fields, :raw, :o, 1}
    ]
end
