defmodule HL7v2.Segment.MFI do
  @moduledoc """
  Master File Identification (MFI) segment -- HL7v2 v2.5.1.

  Contains identification information for a master file.
  6 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "MFI",
    fields: [
      {1, :master_file_identifier, HL7v2.Type.CE, :r, 1},
      {2, :master_file_application_identifier, HL7v2.Type.HD, :o, :unbounded},
      {3, :file_level_event_code, HL7v2.Type.ID, :r, 1},
      {4, :entered_date_time, HL7v2.Type.TS, :o, 1},
      {5, :effective_date_time, HL7v2.Type.TS, :o, 1},
      {6, :response_level_code, HL7v2.Type.ID, :r, 1}
    ]
end
