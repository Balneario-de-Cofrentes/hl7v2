defmodule HL7v2.Segment.IIMTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.IIM

  describe "fields/0" do
    test "returns 15 field definitions" do
      assert length(IIM.fields()) == 15
    end
  end

  describe "segment_id/0" do
    test "returns IIM" do
      assert IIM.segment_id() == "IIM"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = IIM.parse([])
      assert %IIM{} = result
      assert result.primary_key_value == nil
    end

    test "parses inventory item master" do
      raw = [
        ["ITEM001", "Syringe 10ml", "SUPPLIES"],
        ["SVC001", "Injection Kit", "SERVICES"],
        "LOT12345",
        ["20271231"],
        nil,
        nil,
        nil,
        "100"
      ]

      result = IIM.parse(raw)
      assert %HL7v2.Type.CWE{identifier: "ITEM001"} = result.primary_key_value
      assert %HL7v2.Type.CWE{identifier: "SVC001"} = result.service_item_code
      assert result.inventory_lot_number == "LOT12345"
      assert %HL7v2.Type.NM{value: "100"} = result.inventory_received_quantity
    end

    test "preserves raw trailing fields" do
      raw = List.duplicate(nil, 10) ++ ["raw_11"]
      result = IIM.parse(raw)
      assert result.field_11 == "raw_11"
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [["ITEM001", "Syringe"], ["SVC001", "Kit"], "LOT12345"]
      encoded = raw |> IIM.parse() |> IIM.encode()
      reparsed = IIM.parse(encoded)
      assert reparsed.primary_key_value.identifier == "ITEM001"
      assert reparsed.inventory_lot_number == "LOT12345"
    end

    test "encodes all-nil struct to empty list" do
      assert IIM.encode(%IIM{}) == []
    end
  end
end
