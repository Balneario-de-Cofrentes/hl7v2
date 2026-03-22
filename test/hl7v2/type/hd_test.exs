defmodule HL7v2.Type.HDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.HD

  doctest HD

  describe "parse/1" do
    test "parses all three components" do
      result = HD.parse(["HOSP", "2.16.840.1.113883.19.4.6", "ISO"])

      assert result.namespace_id == "HOSP"
      assert result.universal_id == "2.16.840.1.113883.19.4.6"
      assert result.universal_id_type == "ISO"
    end

    test "parses namespace ID only" do
      result = HD.parse(["MRN"])

      assert result.namespace_id == "MRN"
      assert result.universal_id == nil
      assert result.universal_id_type == nil
    end

    test "parses empty list" do
      result = HD.parse([])
      assert %HD{} = result
    end

    test "parses with only universal ID and type" do
      result = HD.parse(["", "2.16.840.1.113883.19.4.6", "ISO"])

      assert result.namespace_id == nil
      assert result.universal_id == "2.16.840.1.113883.19.4.6"
      assert result.universal_id_type == "ISO"
    end
  end

  describe "encode/1" do
    test "encodes nil returns empty list" do
      assert HD.encode(nil) == []
    end

    test "encodes empty struct" do
      assert HD.encode(%HD{}) == []
    end

    test "encodes all three components" do
      hd = %HD{namespace_id: "HOSP", universal_id: "1.2.3", universal_id_type: "ISO"}
      assert HD.encode(hd) == ["HOSP", "1.2.3", "ISO"]
    end

    test "encodes with namespace ID only (trims trailing)" do
      hd = %HD{namespace_id: "MRN"}
      assert HD.encode(hd) == ["MRN"]
    end

    test "encodes with only universal ID and type" do
      hd = %HD{universal_id: "1.2.3", universal_id_type: "ISO"}
      assert HD.encode(hd) == ["", "1.2.3", "ISO"]
    end

    test "encode round-trip" do
      original = %HD{namespace_id: "HOSP", universal_id: "1.2.3", universal_id_type: "ISO"}
      parsed = original |> HD.encode() |> HD.parse()
      assert parsed == original
    end
  end
end
