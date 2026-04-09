defmodule HL7v2.Segment.OBX do
  @moduledoc """
  Observation/Result (OBX) segment -- HL7v2 v2.5.1, with v2.7+ extensions.

  Carries a single observation value. OBX-5 type varies based on OBX-2 (Value Type).
  19 fields per HL7 v2.5.1 specification, plus v2.7+ optional fields 20-25:
  observation site (CWE), observation instance identifier (EI), mood code (CNE),
  performing organization name (XON), address (XAD), and medical director (XCN).

  After base parsing, OBX-5 (observation_value) is re-parsed through
  `HL7v2.Segment.OBXValue` using the data type declared in OBX-2 (value_type).
  Unsupported value types are preserved as raw values. See `HL7v2.Segment.OBXValue`
  for the full list of supported OBX-2 codes.
  """

  use HL7v2.Segment,
    id: "OBX",
    fields: [
      {1, :set_id, HL7v2.Type.SI, :o, 1},
      {2, :value_type, HL7v2.Type.ID, :c, 1},
      {3, :observation_identifier, HL7v2.Type.CE, :r, 1},
      {4, :observation_sub_id, HL7v2.Type.ST, :c, 1},
      {5, :observation_value, :raw, :c, :unbounded},
      {6, :units, HL7v2.Type.CE, :o, 1},
      {7, :references_range, HL7v2.Type.ST, :o, 1},
      {8, :abnormal_flags, HL7v2.Type.IS, :o, :unbounded},
      {9, :probability, HL7v2.Type.NM, :o, 1},
      {10, :nature_of_abnormal_test, HL7v2.Type.ID, :o, :unbounded},
      {11, :observation_result_status, HL7v2.Type.ID, :r, 1},
      {12, :effective_date_of_reference_range, HL7v2.Type.TS, :o, 1},
      {13, :user_defined_access_checks, HL7v2.Type.ST, :o, 1},
      {14, :date_time_of_the_observation, HL7v2.Type.TS, :o, 1},
      {15, :producers_id, HL7v2.Type.CE, :o, 1},
      {16, :responsible_observer, HL7v2.Type.XCN, :o, :unbounded},
      {17, :observation_method, HL7v2.Type.CE, :o, :unbounded},
      {18, :equipment_instance_identifier, HL7v2.Type.EI, :o, :unbounded},
      {19, :date_time_of_the_analysis, HL7v2.Type.TS, :o, 1},
      # v2.7+ fields
      {20, :observation_site, HL7v2.Type.CWE, :o, :unbounded},
      {21, :observation_instance_identifier, HL7v2.Type.EI, :o, 1},
      {22, :mood_code, HL7v2.Type.CNE, :o, 1},
      {23, :performing_organization_name, HL7v2.Type.XON, :o, 1},
      {24, :performing_organization_address, HL7v2.Type.XAD, :o, 1},
      {25, :performing_organization_medical_director, HL7v2.Type.XCN, :o, 1}
    ]

  alias HL7v2.Segment.OBXValue

  @impl HL7v2.Segment
  @spec parse(list(), HL7v2.Separator.t()) :: t()
  def parse(raw_fields, separators \\ HL7v2.Separator.default()) do
    obx = HL7v2.Segment.do_parse(__MODULE__, @segment_fields, raw_fields, separators)

    case obx.value_type do
      nil ->
        obx

      vt ->
        parsed = OBXValue.parse(obx.observation_value, vt)
        %{obx | observation_value: parsed}
    end
  end

  @impl HL7v2.Segment
  @spec encode(t()) :: list()
  def encode(%__MODULE__{} = obx) do
    # Convert typed observation_value back to raw before base encode
    raw_obx =
      case obx.value_type do
        nil ->
          obx

        vt ->
          raw_value = OBXValue.encode(obx.observation_value, vt)
          %{obx | observation_value: raw_value}
      end

    HL7v2.Segment.do_encode(raw_obx, @segment_fields)
  end
end
