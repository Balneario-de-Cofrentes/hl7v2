defmodule HL7v2.Segment.SDDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.SDD

  describe "fields/0" do
    test "returns 7 field definitions" do
      assert length(SDD.fields()) == 7
    end
  end

  describe "segment_id/0" do
    test "returns SDD" do
      assert SDD.segment_id() == "SDD"
    end
  end

  describe "parse/1" do
    test "parses device info" do
      raw = [["LOT001", "MFG"], ["DEV001", "MFG"], "Autoclave Model X"]

      result = SDD.parse(raw)

      assert %SDD{} = result
      assert %HL7v2.Type.EI{entity_identifier: "LOT001"} = result.lot_number
      assert %HL7v2.Type.EI{entity_identifier: "DEV001"} = result.device_number
      assert result.device_name == "Autoclave Model X"
    end

    test "parses operator_name" do
      raw = List.duplicate("", 6) ++ ["John Smith"]

      result = SDD.parse(raw)

      assert result.operator_name == "John Smith"
    end

    test "parses empty list" do
      result = SDD.parse([])

      assert %SDD{} = result
      assert result.lot_number == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert SDD.encode(%SDD{}) == []
    end

    test "round-trip preserves data" do
      raw = [["LOT001", "MFG"], ["DEV001", "MFG"], "Autoclave"]

      encoded = raw |> SDD.parse() |> SDD.encode()

      assert Enum.at(encoded, 0) == ["LOT001", "MFG"]
      assert Enum.at(encoded, 2) == "Autoclave"
    end
  end
end
