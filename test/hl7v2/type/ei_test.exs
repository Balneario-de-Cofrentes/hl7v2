defmodule HL7v2.Type.EITest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.EI

  doctest EI

  describe "parse/1" do
    test "parses all four components" do
      result = EI.parse(["ORD12345", "HOSP", "2.16.840.1.113883.19.4.6", "ISO"])

      assert result.entity_identifier == "ORD12345"
      assert result.namespace_id == "HOSP"
      assert result.universal_id == "2.16.840.1.113883.19.4.6"
      assert result.universal_id_type == "ISO"
    end

    test "parses entity identifier only" do
      result = EI.parse(["ORD12345"])

      assert result.entity_identifier == "ORD12345"
      assert result.namespace_id == nil
    end

    test "parses empty list" do
      result = EI.parse([])
      assert %EI{} = result
    end
  end

  describe "encode/1" do
    test "encodes nil returns empty list" do
      assert EI.encode(nil) == []
    end

    test "encodes empty struct" do
      assert EI.encode(%EI{}) == []
    end

    test "encodes all four components" do
      ei = %EI{entity_identifier: "ORD12345", namespace_id: "HOSP", universal_id: "1.2.3", universal_id_type: "ISO"}
      assert EI.encode(ei) == ["ORD12345", "HOSP", "1.2.3", "ISO"]
    end

    test "encodes with entity identifier only (trims trailing)" do
      ei = %EI{entity_identifier: "ORD12345"}
      assert EI.encode(ei) == ["ORD12345"]
    end

    test "encodes with entity identifier and namespace (trims trailing)" do
      ei = %EI{entity_identifier: "ORD12345", namespace_id: "HOSP"}
      assert EI.encode(ei) == ["ORD12345", "HOSP"]
    end

    test "encode round-trip" do
      original = %EI{entity_identifier: "ORD12345", namespace_id: "HOSP", universal_id: "1.2.3", universal_id_type: "ISO"}
      parsed = original |> EI.encode() |> EI.parse()
      assert parsed == original
    end
  end
end
