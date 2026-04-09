defmodule HL7v2.Segment.STZTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.STZ
  alias HL7v2.Validation.FieldRules

  describe "fields/0" do
    test "returns 3 field definitions" do
      assert length(STZ.fields()) == 3
    end
  end

  describe "segment_id/0" do
    test "returns STZ" do
      assert STZ.segment_id() == "STZ"
    end
  end

  describe "parse/1" do
    test "parses required sterilization_type field" do
      raw = [
        ["STEAM", "Steam Sterilization"],
        ["PREVAC", "Pre-vacuum Cycle"],
        ["DAILY", "Daily Maintenance"]
      ]

      result = STZ.parse(raw)

      assert %STZ{} = result

      assert %HL7v2.Type.CWE{identifier: "STEAM", text: "Steam Sterilization"} =
               result.sterilization_type

      assert %HL7v2.Type.CWE{identifier: "PREVAC", text: "Pre-vacuum Cycle"} =
               result.sterilization_cycle

      assert %HL7v2.Type.CWE{identifier: "DAILY", text: "Daily Maintenance"} =
               result.maintenance_cycle
    end

    test "parses empty list — all fields nil" do
      result = STZ.parse([])

      assert %STZ{} = result
      assert result.sterilization_type == nil
      assert result.sterilization_cycle == nil
      assert result.maintenance_cycle == nil
    end
  end

  describe "encode/1 round-trip" do
    test "preserves all fields through parse → encode → parse" do
      raw = [
        ["STEAM", "Steam Sterilization"],
        ["PREVAC", "Pre-vacuum Cycle"],
        ["DAILY", "Daily Maintenance"]
      ]

      parsed = STZ.parse(raw)
      encoded = STZ.encode(parsed)
      reparsed = STZ.parse(encoded)

      assert reparsed.sterilization_type.identifier == "STEAM"
      assert reparsed.sterilization_type.text == "Steam Sterilization"
      assert reparsed.sterilization_cycle.identifier == "PREVAC"
      assert reparsed.sterilization_cycle.text == "Pre-vacuum Cycle"
      assert reparsed.maintenance_cycle.identifier == "DAILY"
      assert reparsed.maintenance_cycle.text == "Daily Maintenance"
    end

    test "encodes all-nil struct to empty list" do
      assert STZ.encode(%STZ{}) == []
    end
  end

  describe "struct construction" do
    test "accepts keyword opts" do
      stz = %STZ{
        sterilization_type: %HL7v2.Type.CWE{identifier: "STEAM", text: "Steam Sterilization"},
        sterilization_cycle: %HL7v2.Type.CWE{identifier: "PREVAC", text: "Pre-vacuum Cycle"},
        maintenance_cycle: %HL7v2.Type.CWE{identifier: "DAILY", text: "Daily Maintenance"}
      }

      assert stz.sterilization_type.identifier == "STEAM"
      assert stz.sterilization_type.text == "Steam Sterilization"
      assert stz.sterilization_cycle.identifier == "PREVAC"
      assert stz.maintenance_cycle.identifier == "DAILY"
    end
  end

  describe "field validation" do
    test "missing required sterilization_type fails typed parsing validation" do
      segment = %STZ{sterilization_type: nil}

      errors = FieldRules.check(segment)

      assert Enum.any?(errors, fn error ->
               error.level == :error and
                 error.location == "STZ" and
                 error.field == :sterilization_type
             end)
    end

    test "required sterilization_type populated passes field rules" do
      segment = %STZ{
        sterilization_type: %HL7v2.Type.CWE{identifier: "STEAM"}
      }

      errors = FieldRules.check(segment)

      refute Enum.any?(errors, &(&1.level == :error))
    end
  end

  describe "typed parsing integration" do
    test "parses STZ wire line in a full message" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.7\r" <>
          "EVN|A01|20260322\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "STZ|STEAM^Steam Sterilization\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      stz = Enum.find(msg.segments, &is_struct(&1, STZ))

      assert %STZ{} = stz
      assert stz.sterilization_type.identifier == "STEAM"
      assert stz.sterilization_type.text == "Steam Sterilization"
    end
  end
end
