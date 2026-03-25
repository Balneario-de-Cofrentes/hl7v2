defmodule HL7v2.Segment.GP1Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.GP1

  describe "fields/0" do
    test "returns 5 field definitions" do
      assert length(GP1.fields()) == 5
    end
  end

  describe "segment_id/0" do
    test "returns GP1" do
      assert GP1.segment_id() == "GP1"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = GP1.parse([])
      assert %GP1{} = result
      assert result.type_of_bill_code == nil
    end

    test "parses grouping/reimbursement visit" do
      raw = [
        "131",
        nil,
        "01"
      ]

      result = GP1.parse(raw)
      assert result.type_of_bill_code == "131"
      assert result.overall_claim_disposition_code == "01"
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["131", nil, "01"]
      encoded = raw |> GP1.parse() |> GP1.encode()
      reparsed = GP1.parse(encoded)
      assert reparsed.type_of_bill_code == "131"
      assert reparsed.overall_claim_disposition_code == "01"
    end

    test "encodes all-nil struct to empty list" do
      assert GP1.encode(%GP1{}) == []
    end
  end
end
