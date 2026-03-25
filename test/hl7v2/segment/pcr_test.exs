defmodule HL7v2.Segment.PCRTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.PCR

  describe "fields/0" do
    test "returns 23 field definitions" do
      assert length(PCR.fields()) == 23
    end
  end

  describe "segment_id/0" do
    test "returns PCR" do
      assert PCR.segment_id() == "PCR"
    end
  end

  describe "parse/1" do
    test "parses implicated_product" do
      raw = [["DRUG1", "Test Drug"]]

      result = PCR.parse(raw)

      assert %PCR{} = result
      assert %HL7v2.Type.CE{identifier: "DRUG1"} = result.implicated_product
    end

    test "parses empty list" do
      result = PCR.parse([])

      assert %PCR{} = result
      assert result.implicated_product == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert PCR.encode(%PCR{}) == []
    end
  end
end
