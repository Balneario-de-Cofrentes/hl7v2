defmodule HL7v2.Segment.ODTTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.ODT

  describe "fields/0" do
    test "returns 3 field definitions" do
      assert length(ODT.fields()) == 3
    end
  end

  describe "segment_id/0" do
    test "returns ODT" do
      assert ODT.segment_id() == "ODT"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = ODT.parse([])
      assert %ODT{} = result
      assert result.tray_type == nil
    end

    test "parses tray type and text instruction" do
      raw = [["LATE", "Late Tray"], nil, "Please deliver after 8pm"]
      result = ODT.parse(raw)

      assert %HL7v2.Type.CE{identifier: "LATE"} = result.tray_type
      assert result.text_instruction == "Please deliver after 8pm"
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [["LATE", "Late Tray"], nil, "Room 101"]
      encoded = raw |> ODT.parse() |> ODT.encode()
      reparsed = ODT.parse(encoded)
      assert reparsed.tray_type.identifier == "LATE"
      assert reparsed.text_instruction == "Room 101"
    end

    test "encodes all-nil struct to empty list" do
      assert ODT.encode(%ODT{}) == []
    end
  end
end
