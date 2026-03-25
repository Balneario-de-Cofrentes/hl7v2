defmodule HL7v2.Segment.NCK do
  @moduledoc """
  System Clock (NCK) segment -- HL7v2 v2.5.1.

  Contains the system date/time for clock synchronization.

  1 field per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "NCK",
    fields: [
      {1, :system_date_time, HL7v2.Type.TS, :r, 1}
    ]
end
