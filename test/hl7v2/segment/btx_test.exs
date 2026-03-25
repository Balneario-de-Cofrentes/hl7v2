defmodule HL7v2.Segment.BTXTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.BTX

  describe "fields/0" do
    test "returns 20 field definitions" do
      assert length(BTX.fields()) == 20
    end
  end

  describe "segment_id/0" do
    test "returns BTX" do
      assert BTX.segment_id() == "BTX"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = BTX.parse([])
      assert %BTX{} = result
      assert result.set_id == nil
    end

    test "parses set_id and key fields" do
      raw = [
        "1",
        ["DON001", "BLOOD_BANK"],
        ["E0150", "Red Blood Cells"],
        nil,
        nil,
        nil,
        nil,
        "2",
        "450"
      ]

      result = BTX.parse(raw)

      assert result.set_id == 1
      assert %HL7v2.Type.EI{entity_identifier: "DON001"} = result.bc_donation_id
      assert %HL7v2.Type.CNE{identifier: "E0150"} = result.bc_component
      assert %HL7v2.Type.NM{value: "2"} = result.bp_quantity
      assert %HL7v2.Type.NM{value: "450"} = result.bp_amount
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert BTX.encode(%BTX{}) == []
    end

    test "round-trip preserves set_id" do
      raw = ["1", ["DON001"]]
      encoded = raw |> BTX.parse() |> BTX.encode()
      reparsed = BTX.parse(encoded)
      assert reparsed.set_id == 1
      assert reparsed.bc_donation_id.entity_identifier == "DON001"
    end
  end
end
