defmodule HL7v2.Segment.RMI do
  @moduledoc """
  Risk Management Incident (RMI) segment -- HL7v2 v2.5.1.

  Contains risk management incident information.

  3 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "RMI",
    fields: [
      {1, :risk_management_incident_code, HL7v2.Type.CE, :o, 1},
      {2, :date_time_incident, HL7v2.Type.TS, :o, 1},
      {3, :incident_type_code, HL7v2.Type.CE, :o, 1}
    ]
end
