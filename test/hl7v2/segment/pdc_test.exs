defmodule HL7v2.Segment.PDCTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.PDC

  describe "fields/0" do
    test "returns 15 field definitions" do
      assert length(PDC.fields()) == 15
    end
  end

  describe "segment_id/0" do
    test "returns PDC" do
      assert PDC.segment_id() == "PDC"
    end
  end

  describe "parse/1" do
    test "parses brand_name and country" do
      raw = [
        [["MFG", "", "", "", "", "", "", "", ""]],
        ["US", "United States"],
        "TestBrand"
      ]

      result = PDC.parse(raw)

      assert %PDC{} = result
      assert %HL7v2.Type.CE{identifier: "US"} = result.country
      assert result.brand_name == "TestBrand"
    end

    test "parses empty list" do
      result = PDC.parse([])

      assert %PDC{} = result
      assert result.brand_name == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert PDC.encode(%PDC{}) == []
    end
  end
end
