defmodule HL7v2.Segment.LRLTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.LRL

  describe "fields/0" do
    test "returns 6 field definitions" do
      assert length(LRL.fields()) == 6
    end
  end

  describe "segment_id/0" do
    test "returns LRL" do
      assert LRL.segment_id() == "LRL"
    end
  end

  describe "parse/1" do
    test "parses location relationship" do
      raw = [["WARD", "301"], "", ["NEAR", "Near"]]

      result = LRL.parse(raw)

      assert %LRL{} = result
      assert %HL7v2.Type.PL{point_of_care: "WARD"} = result.primary_key_value
      assert %HL7v2.Type.CE{identifier: "NEAR"} = result.location_relationship_id
    end

    test "parses empty list" do
      result = LRL.parse([])

      assert %LRL{} = result
      assert result.primary_key_value == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert LRL.encode(%LRL{}) == []
    end
  end
end
