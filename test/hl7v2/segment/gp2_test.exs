defmodule HL7v2.Segment.GP2Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.GP2

  describe "fields/0" do
    test "returns 14 field definitions" do
      assert length(GP2.fields()) == 14
    end
  end

  describe "segment_id/0" do
    test "returns GP2" do
      assert GP2.segment_id() == "GP2"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = GP2.parse([])
      assert %GP2{} = result
      assert result.revenue_code == nil
    end

    test "parses procedure line item" do
      raw = [
        "0250",
        "3",
        nil,
        "0"
      ]

      result = GP2.parse(raw)
      assert result.revenue_code == "0250"
      assert %HL7v2.Type.NM{value: "3"} = result.number_of_service_units
      assert result.reimbursement_action_code == "0"
    end

    test "parses typed trailing fields" do
      raw = List.duplicate(nil, 10) ++ [["150.00", "USD"]]
      result = GP2.parse(raw)
      assert %HL7v2.Type.CP{} = result.expected_cms_payment_amount
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["0250", "3"]
      encoded = raw |> GP2.parse() |> GP2.encode()
      reparsed = GP2.parse(encoded)
      assert reparsed.revenue_code == "0250"
      assert %HL7v2.Type.NM{value: "3"} = reparsed.number_of_service_units
    end

    test "encodes all-nil struct to empty list" do
      assert GP2.encode(%GP2{}) == []
    end
  end
end
