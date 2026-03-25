defmodule HL7v2.Segment.SCDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.SCD

  describe "fields/0" do
    test "returns 36 field definitions" do
      assert length(SCD.fields()) == 36
    end
  end

  describe "segment_id/0" do
    test "returns SCD" do
      assert SCD.segment_id() == "SCD"
    end
  end

  describe "parse/1" do
    test "parses cycle_count" do
      raw = ["", "5"]

      result = SCD.parse(raw)

      assert %SCD{} = result
      assert %HL7v2.Type.NM{value: "5"} = result.cycle_count
    end

    test "parses empty list" do
      result = SCD.parse([])

      assert %SCD{} = result
      assert result.cycle_start_time == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert SCD.encode(%SCD{}) == []
    end
  end
end
