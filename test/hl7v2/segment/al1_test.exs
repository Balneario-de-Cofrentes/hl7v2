defmodule HL7v2.Segment.AL1Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.AL1

  describe "fields/0" do
    test "returns 6 field definitions" do
      assert length(AL1.fields()) == 6
    end
  end

  describe "segment_id/0" do
    test "returns AL1" do
      assert AL1.segment_id() == "AL1"
    end
  end

  describe "parse/1" do
    test "parses with allergen info" do
      raw = [
        "1",
        ["DA", "Drug allergy", "HL70127"],
        ["70618", "Penicillin", "RxNorm"]
      ]

      result = AL1.parse(raw)

      assert %AL1{} = result
      assert result.set_id == 1

      assert %HL7v2.Type.CE{
               identifier: "DA",
               text: "Drug allergy",
               name_of_coding_system: "HL70127"
             } = result.allergen_type_code

      assert %HL7v2.Type.CE{
               identifier: "70618",
               text: "Penicillin",
               name_of_coding_system: "RxNorm"
             } = result.allergen_code
    end

    test "parses allergy_severity_code as CE" do
      raw = [
        "1",
        ["DA", "Drug allergy"],
        ["70618", "Penicillin"],
        ["SV", "Severe", "HL70128"]
      ]

      result = AL1.parse(raw)

      assert %HL7v2.Type.CE{identifier: "SV", text: "Severe"} = result.allergy_severity_code
    end

    test "parses repeating allergy_reaction_code" do
      raw = [
        "1",
        ["DA", "Drug allergy"],
        ["70618", "Penicillin"],
        "",
        ["Hives", "Anaphylaxis", "Rash"]
      ]

      result = AL1.parse(raw)

      assert result.allergy_reaction_code == ["Hives", "Anaphylaxis", "Rash"]
    end

    test "parses single allergy_reaction_code as list" do
      raw = [
        "1",
        ["DA", "Drug allergy"],
        ["70618", "Penicillin"],
        "",
        "Rash"
      ]

      result = AL1.parse(raw)

      assert result.allergy_reaction_code == ["Rash"]
    end

    test "parses identification_date as DT" do
      raw = [
        "1",
        ["DA", "Drug allergy"],
        ["70618", "Penicillin"],
        "",
        "",
        "20250115"
      ]

      result = AL1.parse(raw)

      assert result.identification_date == ~D[2025-01-15]
    end

    test "parses empty list — all fields nil" do
      result = AL1.parse([])

      assert %AL1{} = result
      assert result.set_id == nil
      assert result.allergen_type_code == nil
      assert result.allergen_code == nil
      assert result.allergy_severity_code == nil
      assert result.allergy_reaction_code == nil
      assert result.identification_date == nil
    end
  end

  describe "encode/1" do
    test "round-trip with allergen info" do
      raw = [
        "1",
        ["DA", "Drug allergy", "HL70127"],
        ["70618", "Penicillin", "RxNorm"]
      ]

      encoded = raw |> AL1.parse() |> AL1.encode()

      assert Enum.at(encoded, 0) == "1"
      assert Enum.at(encoded, 1) == ["DA", "Drug allergy", "HL70127"]
      assert Enum.at(encoded, 2) == ["70618", "Penicillin", "RxNorm"]
    end

    test "round-trip with repeating allergy_reaction_code" do
      raw = [
        "1",
        ["DA", "Drug allergy"],
        ["70618", "Penicillin"],
        "",
        ["Hives", "Anaphylaxis"]
      ]

      encoded = raw |> AL1.parse() |> AL1.encode()

      # Multiple repetitions of ST produce wrapped values
      assert Enum.at(encoded, 4) == [["Hives"], ["Anaphylaxis"]]
    end

    test "trailing nil fields trimmed" do
      al1 = %AL1{set_id: 1, allergen_code: %HL7v2.Type.CE{identifier: "70618"}}

      encoded = AL1.encode(al1)

      assert length(encoded) == 3
      assert Enum.at(encoded, 0) == "1"
    end

    test "encodes all-nil struct to empty list" do
      assert AL1.encode(%AL1{}) == []
    end
  end
end
