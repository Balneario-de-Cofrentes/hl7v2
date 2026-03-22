defmodule HL7v2.Type.CNETest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.CNE

  doctest CNE

  describe "parse/1" do
    test "parses all 9 components" do
      result =
        CNE.parse([
          "F",
          "Female",
          "HL70001",
          "W",
          "Woman",
          "LOCAL",
          "2.5.1",
          "1.0",
          "Originally Female"
        ])

      assert %CNE{
               identifier: "F",
               text: "Female",
               name_of_coding_system: "HL70001",
               alternate_identifier: "W",
               alternate_text: "Woman",
               name_of_alternate_coding_system: "LOCAL",
               coding_system_version_id: "2.5.1",
               alternate_coding_system_version_id: "1.0",
               original_text: "Originally Female"
             } = result
    end

    test "parses with only identifier" do
      result = CNE.parse(["F"])

      assert result.identifier == "F"
      assert result.text == nil
      assert result.name_of_coding_system == nil
    end

    test "parses empty list" do
      result = CNE.parse([])

      assert %CNE{} = result
      assert result.identifier == nil
    end

    test "parses with empty strings treated as nil" do
      result = CNE.parse(["F", "", ""])

      assert result.identifier == "F"
      assert result.text == nil
      assert result.name_of_coding_system == nil
    end
  end

  describe "encode/1" do
    test "encodes nil returns empty list" do
      assert CNE.encode(nil) == []
    end

    test "encodes full struct" do
      cne = %CNE{
        identifier: "F",
        text: "Female",
        name_of_coding_system: "HL70001",
        alternate_identifier: "W",
        alternate_text: "Woman",
        name_of_alternate_coding_system: "LOCAL",
        coding_system_version_id: "2.5.1",
        alternate_coding_system_version_id: "1.0",
        original_text: "Originally Female"
      }

      assert CNE.encode(cne) == [
               "F",
               "Female",
               "HL70001",
               "W",
               "Woman",
               "LOCAL",
               "2.5.1",
               "1.0",
               "Originally Female"
             ]
    end

    test "encodes with trailing nils trimmed" do
      cne = %CNE{identifier: "F", text: "Female", name_of_coding_system: "HL70001"}

      assert CNE.encode(cne) == ["F", "Female", "HL70001"]
    end

    test "encodes empty struct" do
      assert CNE.encode(%CNE{}) == []
    end

    test "encode round-trip preserves data" do
      original = %CNE{
        identifier: "F",
        text: "Female",
        name_of_coding_system: "HL70001",
        original_text: "Originally Female"
      }

      parsed = original |> CNE.encode() |> CNE.parse()

      assert parsed.identifier == "F"
      assert parsed.text == "Female"
      assert parsed.name_of_coding_system == "HL70001"
      assert parsed.original_text == "Originally Female"
    end
  end
end
