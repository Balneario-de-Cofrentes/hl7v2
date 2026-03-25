defmodule HL7v2.Segment.OM2Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.OM2

  describe "fields/0" do
    test "returns 10 field definitions" do
      assert length(OM2.fields()) == 10
    end
  end

  describe "segment_id/0" do
    test "returns OM2" do
      assert OM2.segment_id() == "OM2"
    end
  end

  describe "parse/1" do
    test "parses units_of_measure" do
      raw = ["1", ["mg/dL", "milligrams per deciliter"]]

      result = OM2.parse(raw)

      assert %OM2{} = result
      assert %HL7v2.Type.CE{identifier: "mg/dL"} = result.units_of_measure
    end

    test "parses empty list" do
      result = OM2.parse([])

      assert %OM2{} = result
      assert result.sequence_number == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert OM2.encode(%OM2{}) == []
    end
  end
end
