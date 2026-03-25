defmodule HL7v2.Segment.OM3Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.OM3

  describe "fields/0" do
    test "returns 7 field definitions" do
      assert length(OM3.fields()) == 7
    end
  end

  describe "segment_id/0" do
    test "returns OM3" do
      assert OM3.segment_id() == "OM3"
    end
  end

  describe "parse/1" do
    test "parses sequence and coding system" do
      raw = ["1", ["LOINC", "LOINC"]]

      result = OM3.parse(raw)

      assert %OM3{} = result
      assert %HL7v2.Type.CE{identifier: "LOINC"} = result.preferred_coding_system
    end

    test "parses value_type" do
      raw = List.duplicate("", 6) ++ ["NM"]

      result = OM3.parse(raw)

      assert result.value_type == "NM"
    end

    test "parses empty list" do
      result = OM3.parse([])

      assert %OM3{} = result
      assert result.sequence_number == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert OM3.encode(%OM3{}) == []
    end
  end
end
