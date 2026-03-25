defmodule HL7v2.Segment.PRCTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.PRC

  describe "fields/0" do
    test "returns 18 field definitions" do
      assert length(PRC.fields()) == 18
    end
  end

  describe "segment_id/0" do
    test "returns PRC" do
      assert PRC.segment_id() == "PRC"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = PRC.parse([])
      assert %PRC{} = result
      assert result.primary_key_value == nil
    end

    test "parses primary key and quantity fields" do
      raw = [["CHG001", "Lab Fee"], nil, nil, nil, nil, nil, "1", "100"]
      result = PRC.parse(raw)

      assert %HL7v2.Type.CE{identifier: "CHG001"} = result.primary_key_value
      assert %HL7v2.Type.NM{value: "1"} = result.minimum_quantity
      assert %HL7v2.Type.NM{value: "100"} = result.maximum_quantity
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert PRC.encode(%PRC{}) == []
    end

    test "round-trip preserves primary key" do
      raw = [["CHG001", "Lab Fee"]]
      encoded = raw |> PRC.parse() |> PRC.encode()
      reparsed = PRC.parse(encoded)
      assert reparsed.primary_key_value.identifier == "CHG001"
    end
  end
end
