defmodule HL7v2.Segment.SFT do
  @moduledoc """
  Software Segment (SFT) — HL7v2 v2.5.1.

  Provides information about the sending application software.
  7 fields per HL7 v2.5.1 specification (field 7 withdrawn).
  """

  use HL7v2.Segment,
    id: "SFT",
    fields: [
      {1, :software_vendor_organization, HL7v2.Type.XON, :r, 1},
      {2, :software_certified_version_or_release_number, HL7v2.Type.ST, :r, 1},
      {3, :software_product_name, HL7v2.Type.ST, :r, 1},
      {4, :software_binary_id, HL7v2.Type.ST, :r, 1},
      {5, :software_product_information, HL7v2.Type.TX, :o, 1},
      {6, :software_install_date, HL7v2.Type.TS, :o, 1}
    ]
end
