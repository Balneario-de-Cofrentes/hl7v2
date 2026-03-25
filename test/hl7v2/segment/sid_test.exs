defmodule HL7v2.Segment.SIDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.SID

  describe "fields/0" do
    test "returns 4 field definitions" do
      assert length(SID.fields()) == 4
    end
  end

  describe "segment_id/0" do
    test "returns SID" do
      assert SID.segment_id() == "SID"
    end
  end

  describe "parse/1" do
    test "parses substance info" do
      raw = [["METH", "Method"], "LOT12345", "CONT001", ["ROCHE", "Roche"]]

      result = SID.parse(raw)

      assert %SID{} = result
      assert %HL7v2.Type.CE{identifier: "METH"} = result.application_method_identifier
      assert result.substance_lot_number == "LOT12345"
      assert result.substance_container_identifier == "CONT001"
      assert %HL7v2.Type.CE{identifier: "ROCHE"} = result.substance_manufacturer_identifier
    end

    test "parses empty list" do
      result = SID.parse([])

      assert %SID{} = result
      assert result.application_method_identifier == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert SID.encode(%SID{}) == []
    end

    test "round-trip preserves data" do
      raw = [["METH", "Method"], "LOT12345"]

      encoded = raw |> SID.parse() |> SID.encode()

      assert Enum.at(encoded, 0) == ["METH", "Method"]
      assert Enum.at(encoded, 1) == "LOT12345"
    end
  end
end
