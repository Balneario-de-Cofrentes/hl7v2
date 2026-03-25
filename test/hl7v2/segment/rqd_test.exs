defmodule HL7v2.Segment.RQDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.RQD

  describe "fields/0" do
    test "returns 10 field definitions" do
      assert length(RQD.fields()) == 10
    end
  end

  describe "segment_id/0" do
    test "returns RQD" do
      assert RQD.segment_id() == "RQD"
    end
  end

  describe "parse/1" do
    test "parses requisition detail" do
      raw = ["1", ["INT001", "Internal Item"], ["EXT001", "External Item"]]

      result = RQD.parse(raw)

      assert result.requisition_line_number == 1
      assert %HL7v2.Type.CE{identifier: "INT001"} = result.item_code_internal
      assert %HL7v2.Type.CE{identifier: "EXT001"} = result.item_code_external
    end

    test "parses requisition_quantity" do
      raw = List.duplicate("", 4) ++ ["10"]

      result = RQD.parse(raw)

      assert %HL7v2.Type.NM{value: "10"} = result.requisition_quantity
    end

    test "parses empty list" do
      result = RQD.parse([])

      assert %RQD{} = result
      assert result.requisition_line_number == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert RQD.encode(%RQD{}) == []
    end
  end
end
