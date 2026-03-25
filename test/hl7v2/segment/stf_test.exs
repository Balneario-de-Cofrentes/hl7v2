defmodule HL7v2.Segment.STFTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.STF

  describe "fields/0" do
    test "returns 38 field definitions" do
      assert length(STF.fields()) == 38
    end
  end

  describe "segment_id/0" do
    test "returns STF" do
      assert STF.segment_id() == "STF"
    end
  end

  describe "parse/1" do
    test "parses primary_key_value and staff_type" do
      raw = [["DR001", "Dr. Smith"], "", "", ["MD"]]

      result = STF.parse(raw)

      assert %STF{} = result
      assert %HL7v2.Type.CE{identifier: "DR001"} = result.primary_key_value
    end

    test "parses active_inactive_flag" do
      raw = List.duplicate("", 6) ++ ["A"]

      result = STF.parse(raw)

      assert result.active_inactive_flag == "A"
    end

    test "parses empty list" do
      result = STF.parse([])

      assert %STF{} = result
      assert result.primary_key_value == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert STF.encode(%STF{}) == []
    end
  end
end
