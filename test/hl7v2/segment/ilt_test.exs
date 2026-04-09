defmodule HL7v2.Segment.ILTTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.ILT
  alias HL7v2.Validation.FieldRules

  describe "fields/0" do
    test "returns 10 field definitions" do
      assert length(ILT.fields()) == 10
    end
  end

  describe "segment_id/0" do
    test "returns ILT" do
      assert ILT.segment_id() == "ILT"
    end
  end

  describe "parse/1" do
    test "parses set_id and inventory_lot_number" do
      raw = [
        "1",
        "LOT12345"
      ]

      result = ILT.parse(raw)

      assert %ILT{} = result
      assert result.set_id == 1
      assert result.inventory_lot_number == "LOT12345"
    end

    test "parses empty list — all fields nil" do
      result = ILT.parse([])

      assert %ILT{} = result
      assert result.set_id == nil
      assert result.inventory_lot_number == nil
      assert result.inventory_expiration_date == nil
    end
  end

  describe "encode/1 round-trip" do
    test "preserves all fields through parse → encode → parse" do
      raw = [
        "1",
        "LOT12345"
      ]

      parsed = ILT.parse(raw)
      encoded = ILT.encode(parsed)
      reparsed = ILT.parse(encoded)

      assert reparsed.set_id == 1
      assert reparsed.inventory_lot_number == "LOT12345"
    end

    test "encodes all-nil struct to empty list" do
      assert ILT.encode(%ILT{}) == []
    end
  end

  describe "struct construction" do
    test "accepts keyword opts" do
      ilt = %ILT{
        set_id: 1,
        inventory_lot_number: "LOT12345",
        inventory_received_quantity: "100"
      }

      assert ilt.set_id == 1
      assert ilt.inventory_lot_number == "LOT12345"
      assert ilt.inventory_received_quantity == "100"
    end
  end

  describe "field validation" do
    test "missing required set_id fails typed parsing validation" do
      segment = %ILT{set_id: nil, inventory_lot_number: "LOT12345"}

      errors = FieldRules.check(segment)

      assert Enum.any?(errors, fn error ->
               error.level == :error and
                 error.location == "ILT" and
                 error.field == :set_id
             end)
    end

    test "required set_id populated passes field rules" do
      segment = %ILT{set_id: 1, inventory_lot_number: "LOT12345"}

      errors = FieldRules.check(segment)

      refute Enum.any?(errors, &(&1.level == :error))
    end
  end

  describe "typed parsing integration" do
    test "parses ILT wire line in a full message" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.7\r" <>
          "EVN|A01|20260322\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "ILT|1|LOT12345\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      ilt = Enum.find(msg.segments, &is_struct(&1, ILT))

      assert %ILT{set_id: 1} = ilt
      assert ilt.inventory_lot_number == "LOT12345"
    end
  end
end
