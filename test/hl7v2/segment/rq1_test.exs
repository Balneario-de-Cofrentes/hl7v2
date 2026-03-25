defmodule HL7v2.Segment.RQ1Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.RQ1

  describe "fields/0" do
    test "returns 7 field definitions" do
      assert length(RQ1.fields()) == 7
    end
  end

  describe "segment_id/0" do
    test "returns RQ1" do
      assert RQ1.segment_id() == "RQ1"
    end
  end

  describe "parse/1" do
    test "parses requisition info" do
      raw = ["100.00", ["MFG001", "Manufacturer"], "CAT001"]

      result = RQ1.parse(raw)

      assert %RQ1{} = result
      assert result.anticipated_price == "100.00"
      assert %HL7v2.Type.CE{identifier: "MFG001"} = result.manufacturer_identifier
      assert result.manufacturers_catalog == "CAT001"
    end

    test "parses taxable and substitute_allowed" do
      raw = List.duplicate("", 5) ++ ["Y", "Y"]

      result = RQ1.parse(raw)

      assert result.taxable == "Y"
      assert result.substitute_allowed == "Y"
    end

    test "parses empty list" do
      result = RQ1.parse([])

      assert %RQ1{} = result
      assert result.anticipated_price == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert RQ1.encode(%RQ1{}) == []
    end
  end
end
