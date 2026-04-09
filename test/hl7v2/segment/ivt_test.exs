defmodule HL7v2.Segment.IVTTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.IVT
  alias HL7v2.Validation.FieldRules

  describe "fields/0" do
    test "returns 26 field definitions" do
      assert length(IVT.fields()) == 26
    end
  end

  describe "segment_id/0" do
    test "returns IVT" do
      assert IVT.segment_id() == "IVT"
    end
  end

  describe "parse/1" do
    test "parses set_id and inventory_location_identifier required fields" do
      raw = [
        "1",
        ["LOC001"],
        "Central Supply",
        ["SRC001"],
        "Warehouse",
        ["ACTIVE", "Active"]
      ]

      result = IVT.parse(raw)

      assert %IVT{} = result
      assert result.set_id == 1
      assert %HL7v2.Type.EI{entity_identifier: "LOC001"} = result.inventory_location_identifier
      assert result.inventory_location_name == "Central Supply"
      assert %HL7v2.Type.EI{entity_identifier: "SRC001"} = result.source_location_identifier
      assert result.source_location_name == "Warehouse"
      assert %HL7v2.Type.CWE{identifier: "ACTIVE", text: "Active"} = result.item_status
    end

    test "parses bin_location_identifier as repeating EI" do
      raw =
        List.duplicate("", 6) ++ [[["BIN001"], ["BIN002"], ["BIN003"]]]

      result = IVT.parse(raw)

      assert [
               %HL7v2.Type.EI{entity_identifier: "BIN001"},
               %HL7v2.Type.EI{entity_identifier: "BIN002"},
               %HL7v2.Type.EI{entity_identifier: "BIN003"}
             ] = result.bin_location_identifier
    end

    test "parses substitute_item_identifier as repeating EI" do
      raw =
        List.duplicate("", 18) ++ [[["SUB001"], ["SUB002"]]]

      result = IVT.parse(raw)

      assert [
               %HL7v2.Type.EI{entity_identifier: "SUB001"},
               %HL7v2.Type.EI{entity_identifier: "SUB002"}
             ] = result.substitute_item_identifier
    end

    test "parses empty list — all fields nil" do
      result = IVT.parse([])

      assert %IVT{} = result
      assert result.set_id == nil
      assert result.inventory_location_identifier == nil
      assert result.inventory_location_name == nil
      assert result.bin_location_identifier == nil
      assert result.substitute_item_identifier == nil
    end
  end

  describe "encode/1 round-trip" do
    test "preserves all fields through parse → encode → parse" do
      raw = [
        "1",
        ["LOC001"],
        "Central Supply",
        ["SRC001"],
        "Warehouse",
        ["ACTIVE", "Active"],
        [["BIN001"], ["BIN002"]],
        ["BOX", "Box"],
        ["EA", "Each"],
        ["ACCT001"],
        "Y",
        ["TX001", "Transaction"],
        "",
        ["HIGH", "High Importance"],
        "Y",
        "N",
        "N",
        "",
        [["SUB001"]],
        ["LTX001"],
        ["ROQ", "Reorder Quantity"],
        "7",
        "30",
        "10",
        "50",
        "Y"
      ]

      parsed = IVT.parse(raw)
      encoded = IVT.encode(parsed)
      reparsed = IVT.parse(encoded)

      assert reparsed.set_id == 1
      assert reparsed.inventory_location_identifier.entity_identifier == "LOC001"
      assert reparsed.inventory_location_name == "Central Supply"
      assert reparsed.source_location_identifier.entity_identifier == "SRC001"
      assert reparsed.source_location_name == "Warehouse"
      assert reparsed.item_status.identifier == "ACTIVE"
      assert reparsed.item_status.text == "Active"

      assert [
               %HL7v2.Type.EI{entity_identifier: "BIN001"},
               %HL7v2.Type.EI{entity_identifier: "BIN002"}
             ] = reparsed.bin_location_identifier

      assert reparsed.order_packaging.identifier == "BOX"
      assert reparsed.issue_packaging.identifier == "EA"
      assert reparsed.default_inventory_asset_account.entity_identifier == "ACCT001"
      assert reparsed.patient_chargeable_indicator == "Y"
      assert reparsed.transaction_code.identifier == "TX001"
      assert reparsed.item_importance_code.identifier == "HIGH"
      assert reparsed.stocked_item_indicator == "Y"
      assert reparsed.consignment_item_indicator == "N"
      assert reparsed.reusable_item_indicator == "N"

      assert [%HL7v2.Type.EI{entity_identifier: "SUB001"}] =
               reparsed.substitute_item_identifier

      assert reparsed.latex_free_substitute_item_identifier.entity_identifier == "LTX001"
      assert reparsed.recommended_reorder_theory.identifier == "ROQ"
      assert reparsed.recommended_safety_stock_days.value == "7"
      assert reparsed.recommended_maximum_days_inventory.value == "30"
      assert reparsed.recommended_order_point.value == "10"
      assert reparsed.recommended_order_amount.value == "50"
      assert reparsed.operating_room_par_level_indicator == "Y"
    end

    test "encodes all-nil struct to empty list" do
      assert IVT.encode(%IVT{}) == []
    end
  end

  describe "struct construction" do
    test "accepts keyword opts" do
      ivt = %IVT{
        set_id: "1",
        inventory_location_identifier: %HL7v2.Type.EI{entity_identifier: "LOC001"},
        inventory_location_name: "Central Supply",
        item_status: %HL7v2.Type.CWE{identifier: "ACTIVE", text: "Active"},
        bin_location_identifier: [
          %HL7v2.Type.EI{entity_identifier: "BIN001"},
          %HL7v2.Type.EI{entity_identifier: "BIN002"}
        ]
      }

      assert ivt.set_id == "1"
      assert ivt.inventory_location_identifier.entity_identifier == "LOC001"
      assert ivt.inventory_location_name == "Central Supply"
      assert ivt.item_status.identifier == "ACTIVE"

      assert [
               %HL7v2.Type.EI{entity_identifier: "BIN001"},
               %HL7v2.Type.EI{entity_identifier: "BIN002"}
             ] = ivt.bin_location_identifier
    end
  end

  describe "field validation" do
    test "missing required set_id fails typed parsing validation" do
      segment = %IVT{
        set_id: nil,
        inventory_location_identifier: %HL7v2.Type.EI{entity_identifier: "LOC001"}
      }

      errors = FieldRules.check(segment)

      assert Enum.any?(errors, fn error ->
               error.level == :error and
                 error.location == "IVT" and
                 error.field == :set_id
             end)
    end

    test "missing required inventory_location_identifier fails typed parsing validation" do
      segment = %IVT{set_id: "1", inventory_location_identifier: nil}

      errors = FieldRules.check(segment)

      assert Enum.any?(errors, fn error ->
               error.level == :error and
                 error.location == "IVT" and
                 error.field == :inventory_location_identifier
             end)
    end

    test "both required fields populated passes field rules" do
      segment = %IVT{
        set_id: "1",
        inventory_location_identifier: %HL7v2.Type.EI{entity_identifier: "LOC001"}
      }

      errors = FieldRules.check(segment)

      refute Enum.any?(errors, &(&1.level == :error))
    end
  end

  describe "typed parsing integration" do
    test "parses IVT wire line in a full message" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.7\r" <>
          "EVN|A01|20260322\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|I\r" <>
          "IVT|1|LOC001|Central Supply\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      ivt = Enum.find(msg.segments, &is_struct(&1, IVT))

      assert %IVT{} = ivt
      assert ivt.set_id == 1
      assert ivt.inventory_location_identifier.entity_identifier == "LOC001"
      assert ivt.inventory_location_name == "Central Supply"
    end
  end
end
