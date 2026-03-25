defmodule HL7v2.Segment.LDPTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.LDP

  describe "fields/0" do
    test "returns 12 field definitions" do
      assert length(LDP.fields()) == 12
    end
  end

  describe "segment_id/0" do
    test "returns LDP" do
      assert LDP.segment_id() == "LDP"
    end
  end

  describe "parse/1" do
    test "parses location and department" do
      raw = [["ICU", "101"], ["MED", "Medicine"]]

      result = LDP.parse(raw)

      assert %LDP{} = result
      assert %HL7v2.Type.PL{point_of_care: "ICU"} = result.primary_key_value
      assert %HL7v2.Type.CE{identifier: "MED"} = result.location_department
    end

    test "parses active_inactive_flag" do
      raw = List.duplicate("", 5) ++ ["A"]

      result = LDP.parse(raw)

      assert result.active_inactive_flag == "A"
    end

    test "parses empty list" do
      result = LDP.parse([])

      assert %LDP{} = result
      assert result.primary_key_value == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert LDP.encode(%LDP{}) == []
    end
  end
end
