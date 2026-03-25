defmodule HL7v2.Segment.OM4Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.OM4

  describe "fields/0" do
    test "returns 14 field definitions" do
      assert length(OM4.fields()) == 14
    end
  end

  describe "segment_id/0" do
    test "returns OM4" do
      assert OM4.segment_id() == "OM4"
    end
  end

  describe "parse/1" do
    test "parses specimen info" do
      raw = ["1", "N", "Red-top tube"]

      result = OM4.parse(raw)

      assert %OM4{} = result
      assert result.derived_specimen == "N"
      assert result.container_description == "Red-top tube"
    end

    test "parses empty list" do
      result = OM4.parse([])

      assert %OM4{} = result
      assert result.sequence_number == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert OM4.encode(%OM4{}) == []
    end
  end
end
