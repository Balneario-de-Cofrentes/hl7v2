defmodule HL7v2.Segment.NPUTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.NPU

  describe "fields/0" do
    test "returns 2 field definitions" do
      assert length(NPU.fields()) == 2
    end
  end

  describe "segment_id/0" do
    test "returns NPU" do
      assert NPU.segment_id() == "NPU"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = NPU.parse([])
      assert %NPU{} = result
      assert result.bed_location == nil
      assert result.bed_status == nil
    end

    test "parses bed location and status" do
      raw = [["WARD1", "ROOM101", "BED-A"], "O"]
      result = NPU.parse(raw)

      assert %HL7v2.Type.PL{point_of_care: "WARD1", room: "ROOM101", bed: "BED-A"} =
               result.bed_location

      assert result.bed_status == "O"
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [["WARD1", "ROOM101", "BED-A"], "O"]
      encoded = raw |> NPU.parse() |> NPU.encode()
      reparsed = NPU.parse(encoded)
      assert reparsed.bed_location.point_of_care == "WARD1"
      assert reparsed.bed_status == "O"
    end

    test "encodes all-nil struct to empty list" do
      assert NPU.encode(%NPU{}) == []
    end
  end
end
