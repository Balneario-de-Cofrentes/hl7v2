defmodule HL7v2.Segment.LCCTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.LCC

  describe "fields/0" do
    test "returns 4 field definitions" do
      assert length(LCC.fields()) == 4
    end
  end

  describe "segment_id/0" do
    test "returns LCC" do
      assert LCC.segment_id() == "LCC"
    end
  end

  describe "parse/1" do
    test "parses location and department" do
      raw = [["WARD", "301", "B"], ["CARD", "Cardiology"]]

      result = LCC.parse(raw)

      assert %LCC{} = result
      assert %HL7v2.Type.PL{point_of_care: "WARD"} = result.primary_key_value
      assert %HL7v2.Type.CE{identifier: "CARD"} = result.location_department
    end

    test "parses empty list" do
      result = LCC.parse([])

      assert %LCC{} = result
      assert result.primary_key_value == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert LCC.encode(%LCC{}) == []
    end
  end
end
