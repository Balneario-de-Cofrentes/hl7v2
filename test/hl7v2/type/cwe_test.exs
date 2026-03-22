defmodule HL7v2.Type.CWETest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.CWE

  doctest CWE

  describe "parse/1" do
    test "parses all 9 components" do
      result =
        CWE.parse([
          "I48.0",
          "Paroxysmal AFib",
          "I10",
          "427.31",
          "AFib",
          "I9C",
          "2021",
          "2019",
          "Original description"
        ])

      assert result.identifier == "I48.0"
      assert result.text == "Paroxysmal AFib"
      assert result.name_of_coding_system == "I10"
      assert result.alternate_identifier == "427.31"
      assert result.alternate_text == "AFib"
      assert result.name_of_alternate_coding_system == "I9C"
      assert result.coding_system_version_id == "2021"
      assert result.alternate_coding_system_version_id == "2019"
      assert result.original_text == "Original description"
    end

    test "parses free-text only (component 9)" do
      result = CWE.parse(["", "", "", "", "", "", "", "", "Free text diagnosis"])

      assert result.identifier == nil
      assert result.original_text == "Free text diagnosis"
    end

    test "parses identifier only" do
      result = CWE.parse(["I48.0"])

      assert result.identifier == "I48.0"
      assert result.text == nil
    end

    test "parses empty list" do
      assert %CWE{} = CWE.parse([])
    end
  end

  describe "encode/1" do
    test "encodes nil returns empty list" do
      assert CWE.encode(nil) == []
    end

    test "encodes empty struct" do
      assert CWE.encode(%CWE{}) == []
    end

    test "encodes full struct" do
      cwe = %CWE{
        identifier: "I48.0",
        text: "AFib",
        name_of_coding_system: "I10",
        alternate_identifier: "427.31",
        alternate_text: "AFib",
        name_of_alternate_coding_system: "I9C",
        coding_system_version_id: "2021",
        alternate_coding_system_version_id: "2019",
        original_text: "Original"
      }

      assert CWE.encode(cwe) == [
               "I48.0",
               "AFib",
               "I10",
               "427.31",
               "AFib",
               "I9C",
               "2021",
               "2019",
               "Original"
             ]
    end

    test "encodes with trailing nils trimmed" do
      cwe = %CWE{identifier: "I48.0", text: "AFib", name_of_coding_system: "I10"}
      assert CWE.encode(cwe) == ["I48.0", "AFib", "I10"]
    end

    test "encodes free-text only" do
      cwe = %CWE{original_text: "Free text"}
      assert CWE.encode(cwe) == ["", "", "", "", "", "", "", "", "Free text"]
    end

    test "encode round-trip" do
      original = %CWE{identifier: "I48.0", text: "AFib", name_of_coding_system: "I10"}
      parsed = original |> CWE.encode() |> CWE.parse()
      assert parsed == original
    end
  end
end
