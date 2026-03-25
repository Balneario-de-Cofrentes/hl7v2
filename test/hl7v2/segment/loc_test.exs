defmodule HL7v2.Segment.LOCTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.LOC

  describe "fields/0" do
    test "returns 9 field definitions" do
      assert length(LOC.fields()) == 9
    end
  end

  describe "segment_id/0" do
    test "returns LOC" do
      assert LOC.segment_id() == "LOC"
    end
  end

  describe "parse/1" do
    test "parses location info" do
      raw = [["ICU", "101"], "ICU Room 101"]

      result = LOC.parse(raw)

      assert %LOC{} = result
      assert %HL7v2.Type.PL{point_of_care: "ICU"} = result.primary_key_value
      assert result.location_description == "ICU Room 101"
    end

    test "parses empty list" do
      result = LOC.parse([])

      assert %LOC{} = result
      assert result.primary_key_value == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert LOC.encode(%LOC{}) == []
    end
  end
end
