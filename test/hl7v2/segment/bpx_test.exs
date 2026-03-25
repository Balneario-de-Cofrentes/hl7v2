defmodule HL7v2.Segment.BPXTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.BPX

  describe "fields/0" do
    test "returns 21 field definitions" do
      assert length(BPX.fields()) == 21
    end
  end

  describe "segment_id/0" do
    test "returns BPX" do
      assert BPX.segment_id() == "BPX"
    end
  end

  describe "parse/1" do
    test "parses set_id and bp_dispense_status" do
      raw = ["1", ["RA", "Released and Available"]]

      result = BPX.parse(raw)

      assert result.set_id == 1
      assert %HL7v2.Type.CWE{identifier: "RA"} = result.bp_dispense_status
    end

    test "parses empty list" do
      result = BPX.parse([])

      assert %BPX{} = result
      assert result.set_id == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert BPX.encode(%BPX{}) == []
    end
  end
end
