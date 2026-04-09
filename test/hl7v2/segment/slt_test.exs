defmodule HL7v2.Segment.SLTTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.SLT
  alias HL7v2.Validation.FieldRules

  describe "fields/0" do
    test "returns 5 field definitions" do
      assert length(SLT.fields()) == 5
    end
  end

  describe "segment_id/0" do
    test "returns SLT" do
      assert SLT.segment_id() == "SLT"
    end
  end

  describe "parse/1" do
    test "parses device_number and lot_number required fields" do
      raw = [
        ["D001"],
        "Autoclave 1",
        ["LOT202604"],
        ["ITEM001"],
        "BC001"
      ]

      result = SLT.parse(raw)

      assert %SLT{} = result
      assert %HL7v2.Type.EI{entity_identifier: "D001"} = result.device_number
      assert result.device_name == "Autoclave 1"
      assert %HL7v2.Type.EI{entity_identifier: "LOT202604"} = result.lot_number
      assert %HL7v2.Type.EI{entity_identifier: "ITEM001"} = result.item_identifier
      assert result.bar_code == "BC001"
    end

    test "parses empty list — all fields nil" do
      result = SLT.parse([])

      assert %SLT{} = result
      assert result.device_number == nil
      assert result.device_name == nil
      assert result.lot_number == nil
      assert result.item_identifier == nil
      assert result.bar_code == nil
    end
  end

  describe "encode/1 round-trip" do
    test "preserves all fields through parse → encode → parse" do
      raw = [
        ["D001"],
        "Autoclave 1",
        ["LOT202604"],
        ["ITEM001"],
        "BC001"
      ]

      parsed = SLT.parse(raw)
      encoded = SLT.encode(parsed)
      reparsed = SLT.parse(encoded)

      assert reparsed.device_number.entity_identifier == "D001"
      assert reparsed.device_name == "Autoclave 1"
      assert reparsed.lot_number.entity_identifier == "LOT202604"
      assert reparsed.item_identifier.entity_identifier == "ITEM001"
      assert reparsed.bar_code == "BC001"
    end

    test "encodes all-nil struct to empty list" do
      assert SLT.encode(%SLT{}) == []
    end
  end

  describe "struct construction" do
    test "accepts keyword opts" do
      slt = %SLT{
        device_number: %HL7v2.Type.EI{entity_identifier: "D001"},
        device_name: "Autoclave 1",
        lot_number: %HL7v2.Type.EI{entity_identifier: "LOT202604"},
        item_identifier: %HL7v2.Type.EI{entity_identifier: "ITEM001"},
        bar_code: "BC001"
      }

      assert slt.device_number.entity_identifier == "D001"
      assert slt.device_name == "Autoclave 1"
      assert slt.lot_number.entity_identifier == "LOT202604"
      assert slt.item_identifier.entity_identifier == "ITEM001"
      assert slt.bar_code == "BC001"
    end
  end

  describe "field validation" do
    test "missing required device_number fails typed parsing validation" do
      segment = %SLT{
        device_number: nil,
        lot_number: %HL7v2.Type.EI{entity_identifier: "LOT202604"}
      }

      errors = FieldRules.check(segment)

      assert Enum.any?(errors, fn error ->
               error.level == :error and
                 error.location == "SLT" and
                 error.field == :device_number
             end)
    end

    test "missing required lot_number fails typed parsing validation" do
      segment = %SLT{
        device_number: %HL7v2.Type.EI{entity_identifier: "D001"},
        lot_number: nil
      }

      errors = FieldRules.check(segment)

      assert Enum.any?(errors, fn error ->
               error.level == :error and
                 error.location == "SLT" and
                 error.field == :lot_number
             end)
    end

    test "both required fields populated passes field rules" do
      segment = %SLT{
        device_number: %HL7v2.Type.EI{entity_identifier: "D001"},
        lot_number: %HL7v2.Type.EI{entity_identifier: "LOT202604"}
      }

      errors = FieldRules.check(segment)

      refute Enum.any?(errors, &(&1.level == :error))
    end
  end

  describe "typed parsing integration" do
    test "parses SLT wire line in a full message" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.7\r" <>
          "EVN|A01|20260322\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|I\r" <>
          "SLT|D001|Autoclave 1|LOT202604||BC001\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      slt = Enum.find(msg.segments, &is_struct(&1, SLT))

      assert %SLT{device_name: "Autoclave 1", bar_code: "BC001"} = slt
      assert slt.device_number.entity_identifier == "D001"
      assert slt.lot_number.entity_identifier == "LOT202604"
    end
  end
end
