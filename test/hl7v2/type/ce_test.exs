defmodule HL7v2.Type.CETest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.CE

  doctest CE

  describe "parse/1" do
    test "parses all 6 components" do
      result =
        CE.parse(["784.0", "Headache", "I9C", "G43.9", "Migraine", "I10"])

      assert result.identifier == "784.0"
      assert result.text == "Headache"
      assert result.name_of_coding_system == "I9C"
      assert result.alternate_identifier == "G43.9"
      assert result.alternate_text == "Migraine"
      assert result.name_of_alternate_coding_system == "I10"
    end

    test "parses identifier only" do
      result = CE.parse(["784.0"])

      assert result.identifier == "784.0"
      assert result.text == nil
    end

    test "parses empty list" do
      assert %CE{} = CE.parse([])
    end
  end

  describe "encode/1" do
    test "encodes nil returns empty list" do
      assert CE.encode(nil) == []
    end

    test "encodes empty struct" do
      assert CE.encode(%CE{}) == []
    end

    test "encodes all 6 components" do
      ce = %CE{
        identifier: "784.0",
        text: "Headache",
        name_of_coding_system: "I9C",
        alternate_identifier: "G43.9",
        alternate_text: "Migraine",
        name_of_alternate_coding_system: "I10"
      }

      assert CE.encode(ce) == ["784.0", "Headache", "I9C", "G43.9", "Migraine", "I10"]
    end

    test "encodes with trailing nils trimmed" do
      ce = %CE{identifier: "784.0", text: "Headache"}
      assert CE.encode(ce) == ["784.0", "Headache"]
    end

    test "encodes identifier only" do
      ce = %CE{identifier: "784.0"}
      assert CE.encode(ce) == ["784.0"]
    end

    test "encode round-trip" do
      original = %CE{identifier: "784.0", text: "Headache", name_of_coding_system: "I9C"}
      parsed = original |> CE.encode() |> CE.parse()
      assert parsed == original
    end
  end
end
