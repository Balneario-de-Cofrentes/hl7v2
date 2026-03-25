defmodule HL7v2.Segment.CM0 do
  @moduledoc """
  Clinical Study Master (CM0) segment — HL7v2 v2.5.1.

  Contains master information about a clinical study or trial.

  11 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "CM0",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :o, 1},
      {2, :sponsor_study_id, HL7v2.Type.EI, :r, 1},
      {3, :alternate_study_id, HL7v2.Type.EI, :o, :unbounded},
      {4, :title_of_study, HL7v2.Type.ST, :r, 1},
      {5, :chairman_of_study, HL7v2.Type.XCN, :o, :unbounded},
      {6, :last_iru_date, HL7v2.Type.DT, :o, 1},
      {7, :total_accrual_to_date, HL7v2.Type.NM, :o, 1},
      {8, :last_accrual_date, HL7v2.Type.DT, :o, 1},
      {9, :contact_for_study, HL7v2.Type.XCN, :o, :unbounded},
      {10, :contacts_telephone_number, HL7v2.Type.XTN, :o, 1},
      {11, :contacts_address, HL7v2.Type.XAD, :o, :unbounded}
    ]
end
