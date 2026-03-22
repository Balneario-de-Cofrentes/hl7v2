defmodule HL7v2.Segment.DG1Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.DG1
  alias HL7v2.Type.{CE, DTM, EI, TS}

  describe "field count" do
    test "defines 21 fields" do
      assert length(DG1.fields()) == 21
    end
  end

  describe "parse/1" do
    test "parses diagnosis info" do
      raw = [
        "1",
        nil,
        ["J18.9", "Pneumonia, unspecified", "I10"],
        nil,
        ["20260315"],
        "A"
      ]

      dg1 = DG1.parse(raw)

      assert dg1.set_id == 1

      assert %CE{
               identifier: "J18.9",
               text: "Pneumonia, unspecified",
               name_of_coding_system: "I10"
             } = dg1.diagnosis_code

      assert %TS{time: %DTM{year: 2026, month: 3, day: 15}} = dg1.diagnosis_date_time
      assert dg1.diagnosis_type == "A"
    end

    test "parses with diagnosis identifier" do
      # Build a raw list up to field 20 (diagnosis_identifier at seq 20)
      raw = List.duplicate(nil, 19) ++ [["DX001", "HOSP"]]

      dg1 = DG1.parse(raw)

      assert %EI{entity_identifier: "DX001", namespace_id: "HOSP"} = dg1.diagnosis_identifier
    end

    test "returns nil for missing optional fields" do
      dg1 = DG1.parse(["1", nil, nil, nil, nil, "A"])

      assert dg1.set_id == 1
      assert dg1.diagnosis_code == nil
      assert dg1.diagnosis_date_time == nil
      assert dg1.diagnosis_type == "A"
    end

    test "parses empty list" do
      dg1 = DG1.parse([])

      assert dg1.set_id == nil
      assert dg1.diagnosis_code == nil
      assert dg1.diagnosis_type == nil
    end
  end

  describe "encode/1" do
    test "encodes DG1 with diagnosis info" do
      dg1 = %DG1{
        set_id: 1,
        diagnosis_code: %CE{
          identifier: "J18.9",
          text: "Pneumonia, unspecified",
          name_of_coding_system: "I10"
        },
        diagnosis_type: "A"
      }

      encoded = DG1.encode(dg1)

      assert Enum.at(encoded, 0) == "1"
      assert Enum.at(encoded, 2) == ["J18.9", "Pneumonia, unspecified", "I10"]
      assert Enum.at(encoded, 5) == "A"
    end

    test "encodes nil segment fields" do
      dg1 = %DG1{set_id: 1, diagnosis_type: "A"}
      encoded = DG1.encode(dg1)

      assert Enum.at(encoded, 0) == "1"
      assert Enum.at(encoded, 5) == "A"
    end
  end

  describe "round-trip" do
    test "parse then encode preserves diagnosis data" do
      raw = [
        "1",
        nil,
        ["J18.9", "Pneumonia, unspecified", "I10"],
        nil,
        nil,
        "A"
      ]

      result = raw |> DG1.parse() |> DG1.encode()

      assert Enum.at(result, 0) == "1"
      assert Enum.at(result, 2) == ["J18.9", "Pneumonia, unspecified", "I10"]
      assert Enum.at(result, 5) == "A"
    end
  end
end
