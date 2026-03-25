defmodule HL7v2.Segment.BLC do
  @moduledoc """
  Blood Code (BLC) segment — HL7v2 v2.5.1.

  Identifies the blood product code and amount for blood bank messages.

  2 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "BLC",
    fields: [
      {1, :blood_product_code, HL7v2.Type.CE, :o, 1},
      {2, :blood_amount, HL7v2.Type.CQ, :o, 1}
    ]
end
