defmodule HL7v2.Segment.BLG do
  @moduledoc """
  Billing (BLG) segment — HL7v2 v2.5.1.

  Contains billing information for charges, including when to charge,
  charge type, and account identification.

  3 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "BLG",
    fields: [
      {1, :when_to_charge, :raw, :o, 1},
      {2, :charge_type, HL7v2.Type.ID, :o, 1},
      {3, :account_id, HL7v2.Type.CX, :o, 1}
    ]
end
