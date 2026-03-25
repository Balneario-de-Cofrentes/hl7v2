defmodule HL7v2.Segment.EQUTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.EQU

  describe "fields/0" do
    test "returns 5 field definitions" do
      assert length(EQU.fields()) == 5
    end
  end

  describe "segment_id/0" do
    test "returns EQU" do
      assert EQU.segment_id() == "EQU"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = EQU.parse([])
      assert %EQU{} = result
      assert result.equipment_instance_identifier == nil
    end

    test "parses equipment detail" do
      raw = [
        ["INST001", "LAB_NS"],
        ["20260315120000"],
        ["IN", "In Use", "EQ_STATES"],
        ["L", "Local", "CTRL_STATES"],
        ["N", "Normal", "ALERT_LEVELS"]
      ]

      result = EQU.parse(raw)
      assert %HL7v2.Type.EI{entity_identifier: "INST001"} = result.equipment_instance_identifier
      assert %HL7v2.Type.TS{} = result.event_date_time
      assert %HL7v2.Type.CE{identifier: "IN"} = result.equipment_state
      assert %HL7v2.Type.CE{identifier: "L"} = result.local_remote_control_state
      assert %HL7v2.Type.CE{identifier: "N"} = result.alert_level
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [["INST001", "NS"], ["20260315"]]
      encoded = raw |> EQU.parse() |> EQU.encode()
      reparsed = EQU.parse(encoded)
      assert reparsed.equipment_instance_identifier.entity_identifier == "INST001"
    end

    test "encodes all-nil struct to empty list" do
      assert EQU.encode(%EQU{}) == []
    end
  end
end
