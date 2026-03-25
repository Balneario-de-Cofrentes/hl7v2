defmodule HL7v2.Segment.IPC do
  @moduledoc """
  Imaging Procedure Control (IPC) segment -- HL7v2 v2.5.1.

  Contains imaging procedure control information.
  9 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "IPC",
    fields: [
      {1, :accession_identifier, HL7v2.Type.EI, :r, 1},
      {2, :requested_procedure_id, HL7v2.Type.EI, :r, 1},
      {3, :study_instance_uid, HL7v2.Type.EI, :r, 1},
      {4, :scheduled_procedure_step_id, HL7v2.Type.EI, :r, 1},
      {5, :modality, HL7v2.Type.CE, :o, 1},
      {6, :protocol_code, HL7v2.Type.CE, :o, :unbounded},
      {7, :scheduled_station_name, HL7v2.Type.EI, :o, 1},
      {8, :scheduled_procedure_step_location_list, HL7v2.Type.CE, :o, :unbounded},
      {9, :scheduled_ae_title, HL7v2.Type.ST, :o, 1}
    ]
end
