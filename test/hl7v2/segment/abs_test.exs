defmodule HL7v2.Segment.ABSTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.ABS

  describe "fields/0" do
    test "returns 13 field definitions" do
      assert length(ABS.fields()) == 13
    end
  end

  describe "segment_id/0" do
    test "returns ABS" do
      assert ABS.segment_id() == "ABS"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = ABS.parse([])
      assert %ABS{} = result
      assert result.discharge_care_provider == nil
      assert result.severity_of_illness_code == nil
    end

    test "parses discharge care provider and severity" do
      raw = [
        ["12345", "Smith", "John"],
        ["MED", "Medicine", "HL70069"],
        ["1", "Mild", "SEV"]
      ]

      result = ABS.parse(raw)

      assert %HL7v2.Type.XCN{id_number: "12345"} = result.discharge_care_provider

      assert %HL7v2.Type.CE{identifier: "MED", text: "Medicine"} =
               result.transfer_medical_service_code

      assert %HL7v2.Type.CE{identifier: "1", text: "Mild"} = result.severity_of_illness_code
    end

    test "parses caesarian section indicator and gestation fields" do
      raw = [nil, nil, nil, nil, nil, nil, nil, nil, nil, "Y", nil, "38"]
      result = ABS.parse(raw)

      assert result.caesarian_section_indicator == "Y"
      assert %HL7v2.Type.NM{value: "38"} = result.gestation_period_weeks
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [
        ["12345", "Smith", "John"],
        ["MED", "Medicine"],
        ["1", "Mild"]
      ]

      encoded = raw |> ABS.parse() |> ABS.encode()
      reparsed = ABS.parse(encoded)
      assert reparsed.discharge_care_provider.id_number == "12345"
      assert reparsed.transfer_medical_service_code.identifier == "MED"
    end

    test "encodes all-nil struct to empty list" do
      assert ABS.encode(%ABS{}) == []
    end
  end
end
