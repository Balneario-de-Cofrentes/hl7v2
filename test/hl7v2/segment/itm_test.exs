defmodule HL7v2.Segment.ITMTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.ITM
  alias HL7v2.Validation.FieldRules

  describe "fields/0" do
    test "returns 18 field definitions" do
      assert length(ITM.fields()) == 18
    end
  end

  describe "segment_id/0" do
    test "returns ITM" do
      assert ITM.segment_id() == "ITM"
    end
  end

  describe "parse/1" do
    test "parses item_identifier required field" do
      raw = [
        ["ITEM001"],
        "Blood Collection Tube",
        ["ACTIVE", "Active"],
        ["DV", "Device"]
      ]

      result = ITM.parse(raw)

      assert %ITM{} = result
      assert %HL7v2.Type.EI{entity_identifier: "ITEM001"} = result.item_identifier
      assert result.item_description == "Blood Collection Tube"
      assert %HL7v2.Type.CWE{identifier: "ACTIVE", text: "Active"} = result.item_status
      assert %HL7v2.Type.CWE{identifier: "DV", text: "Device"} = result.item_type
    end

    test "parses approving_regulatory_agency as repeating XON" do
      raw =
        List.duplicate("", 15) ++
          [[["FDA", "L"], ["CE Mark", "L"]]]

      result = ITM.parse(raw)

      assert [
               %HL7v2.Type.XON{organization_name: "FDA"},
               %HL7v2.Type.XON{organization_name: "CE Mark"}
             ] = result.approving_regulatory_agency
    end

    test "parses ruling_act as repeating CWE" do
      raw =
        List.duplicate("", 17) ++
          [[["ACT1", "Ruling Act One"], ["ACT2", "Ruling Act Two"]]]

      result = ITM.parse(raw)

      assert [
               %HL7v2.Type.CWE{identifier: "ACT1", text: "Ruling Act One"},
               %HL7v2.Type.CWE{identifier: "ACT2", text: "Ruling Act Two"}
             ] = result.ruling_act
    end

    test "parses empty list — all fields nil" do
      result = ITM.parse([])

      assert %ITM{} = result
      assert result.item_identifier == nil
      assert result.item_description == nil
      assert result.item_status == nil
      assert result.approving_regulatory_agency == nil
      assert result.ruling_act == nil
    end
  end

  describe "encode/1 round-trip" do
    test "preserves all fields through parse → encode → parse" do
      raw = [
        ["ITEM001"],
        "Blood Collection Tube",
        ["ACTIVE", "Active"],
        ["DV", "Device"],
        ["LAB", "Laboratory"],
        "N",
        ["MFR001"],
        "Becton Dickinson",
        "BD1234",
        ["LBL001", "Labeler"],
        "Y",
        ["TX001", "Transaction"],
        "",
        "Y",
        ["LOW", "Low Risk"],
        [["FDA", "L"]],
        "N",
        [["ACT1", "Ruling Act One"]]
      ]

      parsed = ITM.parse(raw)
      encoded = ITM.encode(parsed)
      reparsed = ITM.parse(encoded)

      assert reparsed.item_identifier.entity_identifier == "ITEM001"
      assert reparsed.item_description == "Blood Collection Tube"
      assert reparsed.item_status.identifier == "ACTIVE"
      assert reparsed.item_status.text == "Active"
      assert reparsed.item_type.identifier == "DV"
      assert reparsed.item_category.identifier == "LAB"
      assert reparsed.subject_to_expiration_indicator == "N"
      assert reparsed.manufacturer_identifier.entity_identifier == "MFR001"
      assert reparsed.manufacturer_name == "Becton Dickinson"
      assert reparsed.manufacturer_catalog_number == "BD1234"
      assert reparsed.manufacturer_labeler_identification_code.identifier == "LBL001"
      assert reparsed.patient_chargeable_indicator == "Y"
      assert reparsed.transaction_code.identifier == "TX001"
      assert reparsed.stocked_item_indicator == "Y"
      assert reparsed.supply_risk_codes.identifier == "LOW"
      assert [%HL7v2.Type.XON{organization_name: "FDA"}] = reparsed.approving_regulatory_agency
      assert reparsed.latex_indicator == "N"
      assert [%HL7v2.Type.CWE{identifier: "ACT1", text: "Ruling Act One"}] = reparsed.ruling_act
    end

    test "encodes all-nil struct to empty list" do
      assert ITM.encode(%ITM{}) == []
    end
  end

  describe "struct construction" do
    test "accepts keyword opts" do
      itm = %ITM{
        item_identifier: %HL7v2.Type.EI{entity_identifier: "ITEM001"},
        item_description: "Blood Collection Tube",
        item_status: %HL7v2.Type.CWE{identifier: "ACTIVE", text: "Active"},
        manufacturer_name: "Becton Dickinson",
        approving_regulatory_agency: [%HL7v2.Type.XON{organization_name: "FDA"}]
      }

      assert itm.item_identifier.entity_identifier == "ITEM001"
      assert itm.item_description == "Blood Collection Tube"
      assert itm.item_status.identifier == "ACTIVE"
      assert itm.manufacturer_name == "Becton Dickinson"

      assert [%HL7v2.Type.XON{organization_name: "FDA"}] =
               itm.approving_regulatory_agency
    end
  end

  describe "field validation" do
    test "missing required item_identifier fails typed parsing validation" do
      segment = %ITM{item_identifier: nil, item_description: "Blood Collection Tube"}

      errors = FieldRules.check(segment)

      assert Enum.any?(errors, fn error ->
               error.level == :error and
                 error.location == "ITM" and
                 error.field == :item_identifier
             end)
    end

    test "populated item_identifier passes field rules" do
      segment = %ITM{
        item_identifier: %HL7v2.Type.EI{entity_identifier: "ITEM001"},
        item_description: "Blood Collection Tube"
      }

      errors = FieldRules.check(segment)

      refute Enum.any?(errors, &(&1.level == :error))
    end
  end

  describe "typed parsing integration" do
    test "parses ITM wire line in a full message" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.7\r" <>
          "EVN|A01|20260322\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|I\r" <>
          "ITM|ITEM001|Blood Collection Tube||DV||N||Becton Dickinson|BD1234\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      itm = Enum.find(msg.segments, &is_struct(&1, ITM))

      assert %ITM{} = itm
      assert itm.item_identifier.entity_identifier == "ITEM001"
      assert itm.item_description == "Blood Collection Tube"
      assert itm.item_type.identifier == "DV"
      assert itm.subject_to_expiration_indicator == "N"
      assert itm.manufacturer_name == "Becton Dickinson"
      assert itm.manufacturer_catalog_number == "BD1234"
    end
  end
end
