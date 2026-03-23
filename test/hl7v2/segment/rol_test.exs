defmodule HL7v2.Segment.ROLTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.ROL

  describe "fields/0" do
    test "returns 12 field definitions" do
      assert length(ROL.fields()) == 12
    end
  end

  describe "segment_id/0" do
    test "returns ROL" do
      assert ROL.segment_id() == "ROL"
    end
  end

  describe "parse/1" do
    test "parses action_code and role" do
      raw = [["R1", "", "", ""], "AD", ["ADMPHYS", "Admitting Physician"]]

      result = ROL.parse(raw)

      assert %ROL{} = result
      assert %HL7v2.Type.EI{entity_identifier: "R1"} = result.role_instance_id
      assert result.action_code == "AD"
      assert %HL7v2.Type.CE{identifier: "ADMPHYS", text: "Admitting Physician"} = result.role
    end

    test "parses role_person as repeating XCN" do
      raw = [
        "",
        "AD",
        ["ADMPHYS", "Admitting"],
        [["12345", "Smith", "John"], ["67890", "Jones", "Mary"]]
      ]

      result = ROL.parse(raw)

      assert [
               %HL7v2.Type.XCN{id_number: "12345"},
               %HL7v2.Type.XCN{id_number: "67890"}
             ] = result.role_person
    end

    test "parses date/time fields" do
      raw = [
        "",
        "AD",
        ["ADMPHYS"],
        [["12345", "Smith"]],
        ["20260315080000"],
        ["20260320170000"]
      ]

      result = ROL.parse(raw)

      assert %HL7v2.Type.TS{
               time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 15, hour: 8}
             } = result.role_begin_date_time

      assert %HL7v2.Type.TS{
               time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 20, hour: 17}
             } = result.role_end_date_time
    end

    test "parses provider_type as repeating CE" do
      raw = List.duplicate("", 8) ++ [[["PHYS", "Physician"], ["SURG", "Surgeon"]]]

      result = ROL.parse(raw)

      assert [
               %HL7v2.Type.CE{identifier: "PHYS"},
               %HL7v2.Type.CE{identifier: "SURG"}
             ] = result.provider_type
    end

    test "parses phone as repeating XTN" do
      raw = List.duplicate("", 11) ++ [[["(555)123-4567"]]]

      result = ROL.parse(raw)

      assert [%HL7v2.Type.XTN{}] = result.phone
    end

    test "parses empty list — all fields nil" do
      result = ROL.parse([])

      assert %ROL{} = result
      assert result.action_code == nil
      assert result.role == nil
      assert result.role_person == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [
        ["R1"],
        "AD",
        ["ADMPHYS", "Admitting Physician"],
        [["12345", "Smith", "John"]]
      ]

      encoded = raw |> ROL.parse() |> ROL.encode()
      reparsed = ROL.parse(encoded)

      assert reparsed.action_code == "AD"
      assert reparsed.role.identifier == "ADMPHYS"
    end

    test "trailing nil fields trimmed" do
      rol = %ROL{action_code: "AD", role: %HL7v2.Type.CE{identifier: "ADMPHYS"}}

      encoded = ROL.encode(rol)

      assert length(encoded) == 3
    end

    test "encodes all-nil struct to empty list" do
      assert ROL.encode(%ROL{}) == []
    end
  end

  describe "typed parsing integration" do
    test "ADT^A01 with ROL parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.5.1\r" <>
          "EVN|A01|20260322\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|I\r" <>
          "ROL||AD|ADMPHYS^Admitting Physician|12345^Smith^John\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      rol = Enum.find(msg.segments, &is_struct(&1, ROL))
      assert %ROL{action_code: "AD"} = rol
      assert rol.role.identifier == "ADMPHYS"
    end
  end
end
