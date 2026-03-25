defmodule HL7v2.Type.CFTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.CF

  doctest CF

  describe "parse/1" do
    test "parses all components" do
      result = CF.parse(["I9", "Diagnosis text", "I9C", "ALT1", "Alt text", "ALT"])
      assert result.identifier == "I9"
      assert result.formatted_text == "Diagnosis text"
      assert result.name_of_coding_system == "I9C"
      assert result.alternate_identifier == "ALT1"
      assert result.alternate_formatted_text == "Alt text"
      assert result.name_of_alternate_coding_system == "ALT"
    end

    test "parses empty list" do
      assert CF.parse([]).identifier == nil
    end
  end

  describe "encode/1" do
    test "encodes full CF" do
      cf = %CF{identifier: "I9", formatted_text: "Text", name_of_coding_system: "I9C"}
      assert CF.encode(cf) == ["I9", "Text", "I9C"]
    end

    test "encodes nil" do
      assert CF.encode(nil) == []
    end
  end

  describe "round-trip" do
    test "full CF round-trips" do
      components = ["I9", "Diagnosis text", "I9C"]
      assert components |> CF.parse() |> CF.encode() == components
    end
  end
end
