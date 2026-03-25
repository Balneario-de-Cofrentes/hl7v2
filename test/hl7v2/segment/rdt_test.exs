defmodule HL7v2.Segment.RDTTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.RDT

  describe "fields/0" do
    test "returns 1 field definition" do
      assert length(RDT.fields()) == 1
    end
  end

  describe "segment_id/0" do
    test "returns RDT" do
      assert RDT.segment_id() == "RDT"
    end
  end

  describe "parse/1" do
    test "parses column_value as raw" do
      raw = ["some value"]

      result = RDT.parse(raw)

      assert %RDT{} = result
      assert result.column_value == "some value"
    end

    test "parses empty list" do
      result = RDT.parse([])

      assert %RDT{} = result
      assert result.column_value == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert RDT.encode(%RDT{}) == []
    end
  end
end
