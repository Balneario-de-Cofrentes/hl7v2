defmodule HL7v2.Segment.SCPTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.SCP
  alias HL7v2.Validation.FieldRules

  describe "fields/0" do
    test "returns 8 field definitions" do
      assert length(SCP.fields()) == 8
    end
  end

  describe "segment_id/0" do
    test "returns SCP" do
      assert SCP.segment_id() == "SCP"
    end
  end

  describe "parse/1" do
    test "parses all 8 required fields" do
      raw = [
        "1",
        ["L", "Labor", "X"],
        ["D", "YYYYMMDD", "X"],
        ["D001"],
        "Autoclave 1",
        "Model 3870M",
        ["A", "Autoclave", "X"],
        ["N", "None", "X"]
      ]

      result = SCP.parse(raw)

      assert %SCP{} = result
      assert %HL7v2.Type.NM{value: "1"} = result.number_of_decontamination_sterilization_devices
      assert %HL7v2.Type.CWE{identifier: "L", text: "Labor"} = result.labor_calculation_type
      assert %HL7v2.Type.CWE{identifier: "D", text: "YYYYMMDD"} = result.date_format
      assert %HL7v2.Type.EI{entity_identifier: "D001"} = result.device_number
      assert result.device_name == "Autoclave 1"
      assert result.device_model_name == "Model 3870M"
      assert %HL7v2.Type.CWE{identifier: "A", text: "Autoclave"} = result.device_type
      assert %HL7v2.Type.CWE{identifier: "N", text: "None"} = result.lot_control
    end

    test "parses empty list — all fields nil" do
      result = SCP.parse([])

      assert %SCP{} = result
      assert result.number_of_decontamination_sterilization_devices == nil
      assert result.labor_calculation_type == nil
      assert result.date_format == nil
      assert result.device_number == nil
      assert result.device_name == nil
      assert result.device_model_name == nil
      assert result.device_type == nil
      assert result.lot_control == nil
    end
  end

  describe "encode/1 round-trip" do
    test "preserves all fields through parse → encode → parse" do
      raw = [
        "1",
        ["L", "Labor", "X"],
        ["D", "YYYYMMDD", "X"],
        ["D001"],
        "Autoclave 1",
        "Model 3870M",
        ["A", "Autoclave", "X"],
        ["N", "None", "X"]
      ]

      parsed = SCP.parse(raw)
      encoded = SCP.encode(parsed)
      reparsed = SCP.parse(encoded)

      assert reparsed.number_of_decontamination_sterilization_devices.value == "1"
      assert reparsed.labor_calculation_type.identifier == "L"
      assert reparsed.labor_calculation_type.text == "Labor"
      assert reparsed.date_format.identifier == "D"
      assert reparsed.date_format.text == "YYYYMMDD"
      assert reparsed.device_number.entity_identifier == "D001"
      assert reparsed.device_name == "Autoclave 1"
      assert reparsed.device_model_name == "Model 3870M"
      assert reparsed.device_type.identifier == "A"
      assert reparsed.device_type.text == "Autoclave"
      assert reparsed.lot_control.identifier == "N"
      assert reparsed.lot_control.text == "None"
    end

    test "encodes all-nil struct to empty list" do
      assert SCP.encode(%SCP{}) == []
    end
  end

  describe "struct construction" do
    test "accepts keyword opts" do
      scp = %SCP{
        number_of_decontamination_sterilization_devices: "1",
        labor_calculation_type: %HL7v2.Type.CWE{identifier: "L", text: "Labor"},
        date_format: %HL7v2.Type.CWE{identifier: "D", text: "YYYYMMDD"},
        device_number: %HL7v2.Type.EI{entity_identifier: "D001"},
        device_name: "Autoclave 1",
        device_model_name: "Model 3870M",
        device_type: %HL7v2.Type.CWE{identifier: "A", text: "Autoclave"},
        lot_control: %HL7v2.Type.CWE{identifier: "N", text: "None"}
      }

      assert scp.number_of_decontamination_sterilization_devices == "1"
      assert scp.labor_calculation_type.identifier == "L"
      assert scp.date_format.text == "YYYYMMDD"
      assert scp.device_number.entity_identifier == "D001"
      assert scp.device_name == "Autoclave 1"
      assert scp.device_model_name == "Model 3870M"
      assert scp.device_type.identifier == "A"
      assert scp.lot_control.identifier == "N"
    end
  end

  describe "field validation" do
    test "missing required device_number fails typed parsing validation" do
      segment = %SCP{
        number_of_decontamination_sterilization_devices: "1",
        labor_calculation_type: %HL7v2.Type.CWE{identifier: "L"},
        date_format: %HL7v2.Type.CWE{identifier: "D"},
        device_number: nil,
        device_name: "Autoclave 1",
        device_model_name: "Model 3870M",
        device_type: %HL7v2.Type.CWE{identifier: "A"},
        lot_control: %HL7v2.Type.CWE{identifier: "N"}
      }

      errors = FieldRules.check(segment)

      assert Enum.any?(errors, fn error ->
               error.level == :error and
                 error.location == "SCP" and
                 error.field == :device_number
             end)
    end

    test "all required fields populated passes field rules" do
      segment = %SCP{
        number_of_decontamination_sterilization_devices: "1",
        labor_calculation_type: %HL7v2.Type.CWE{identifier: "L"},
        date_format: %HL7v2.Type.CWE{identifier: "D"},
        device_number: %HL7v2.Type.EI{entity_identifier: "D001"},
        device_name: "Autoclave 1",
        device_model_name: "Model 3870M",
        device_type: %HL7v2.Type.CWE{identifier: "A"},
        lot_control: %HL7v2.Type.CWE{identifier: "N"}
      }

      errors = FieldRules.check(segment)

      refute Enum.any?(errors, &(&1.level == :error))
    end
  end

  describe "typed parsing integration" do
    test "parses SCP wire line in a full message" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.7\r" <>
          "EVN|A01|20260322\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "SCP|1|L^Labor^X|D^YYYYMMDD^X|D001|Autoclave 1|Model 3870M|A^Autoclave^X|N^None^X\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      scp = Enum.find(msg.segments, &is_struct(&1, SCP))

      assert %SCP{} = scp
      assert scp.number_of_decontamination_sterilization_devices.value == "1"
      assert scp.labor_calculation_type.identifier == "L"
      assert scp.labor_calculation_type.text == "Labor"
      assert scp.date_format.identifier == "D"
      assert scp.date_format.text == "YYYYMMDD"
      assert scp.device_number.entity_identifier == "D001"
      assert scp.device_name == "Autoclave 1"
      assert scp.device_model_name == "Model 3870M"
      assert scp.device_type.identifier == "A"
      assert scp.lot_control.identifier == "N"
    end
  end
end
