defmodule HL7v2.Segment.BLCTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.BLC

  describe "fields/0" do
    test "returns 2 field definitions" do
      assert length(BLC.fields()) == 2
    end
  end

  describe "segment_id/0" do
    test "returns BLC" do
      assert BLC.segment_id() == "BLC"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = BLC.parse([])
      assert %BLC{} = result
      assert result.blood_product_code == nil
      assert result.blood_amount == nil
    end

    test "parses blood code fields" do
      raw = [["E0150", "Red Blood Cells", "ABO"], ["2", "units"]]
      result = BLC.parse(raw)

      assert %HL7v2.Type.CE{identifier: "E0150", text: "Red Blood Cells"} =
               result.blood_product_code

      assert %HL7v2.Type.CQ{quantity: "2"} = result.blood_amount
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [["E0150", "Red Blood Cells"], ["3", "units"]]
      encoded = raw |> BLC.parse() |> BLC.encode()
      reparsed = BLC.parse(encoded)
      assert reparsed.blood_product_code.identifier == "E0150"
      assert reparsed.blood_amount.quantity == "3"
    end

    test "encodes all-nil struct to empty list" do
      assert BLC.encode(%BLC{}) == []
    end
  end
end
