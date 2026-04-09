defmodule HL7v2.Segment.PRTTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.PRT
  alias HL7v2.Validation.FieldRules

  describe "fields/0" do
    test "returns 10 field definitions" do
      assert length(PRT.fields()) == 10
    end
  end

  describe "segment_id/0" do
    test "returns PRT" do
      assert PRT.segment_id() == "PRT"
    end
  end

  describe "parse/1" do
    test "parses action_code and participation required fields" do
      raw = [
        ["1"],
        "AD",
        "",
        ["CP", "Collecting Provider"],
        [["1234", "Smith", "Jane"]],
        "",
        "",
        "",
        [["POC", "101", "A"]],
        [["DEV001"]]
      ]

      result = PRT.parse(raw)

      assert %PRT{} = result
      assert %HL7v2.Type.EI{entity_identifier: "1"} = result.participation_instance_id
      assert result.action_code == "AD"

      assert %HL7v2.Type.CWE{identifier: "CP", text: "Collecting Provider"} =
               result.participation
    end

    test "parses participation_person as repeating XCN" do
      raw = [
        "",
        "AD",
        "",
        ["CP"],
        [["1234", "Smith", "Jane"], ["5678", "Doe", "John"]]
      ]

      result = PRT.parse(raw)

      assert [
               %HL7v2.Type.XCN{id_number: "1234"},
               %HL7v2.Type.XCN{id_number: "5678"}
             ] = result.participation_person
    end

    test "parses participant_location as repeating PL" do
      raw =
        List.duplicate("", 8) ++ [[["POC", "101", "A"]]]

      result = PRT.parse(raw)

      assert [%HL7v2.Type.PL{point_of_care: "POC", room: "101", bed: "A"}] =
               result.participant_location
    end

    test "parses participation_device as repeating EI" do
      raw =
        List.duplicate("", 9) ++ [[["DEV001"], ["DEV002"]]]

      result = PRT.parse(raw)

      assert [
               %HL7v2.Type.EI{entity_identifier: "DEV001"},
               %HL7v2.Type.EI{entity_identifier: "DEV002"}
             ] = result.participation_device
    end

    test "parses empty list — all fields nil" do
      result = PRT.parse([])

      assert %PRT{} = result
      assert result.action_code == nil
      assert result.participation == nil
      assert result.participation_person == nil
    end
  end

  describe "encode/1 round-trip" do
    test "preserves all fields through parse → encode → parse" do
      raw = [
        ["1"],
        "AD",
        "",
        ["CP", "Collecting Provider"],
        [["1234", "Smith", "Jane"]],
        "",
        "",
        "",
        [["POC", "101", "A"]],
        [["DEV001"]]
      ]

      parsed = PRT.parse(raw)
      encoded = PRT.encode(parsed)
      reparsed = PRT.parse(encoded)

      assert reparsed.participation_instance_id.entity_identifier == "1"
      assert reparsed.action_code == "AD"
      assert reparsed.participation.identifier == "CP"
      assert reparsed.participation.text == "Collecting Provider"
      assert [%HL7v2.Type.XCN{id_number: "1234"}] = reparsed.participation_person

      assert [%HL7v2.Type.PL{point_of_care: "POC", room: "101", bed: "A"}] =
               reparsed.participant_location

      assert [%HL7v2.Type.EI{entity_identifier: "DEV001"}] = reparsed.participation_device
    end

    test "encodes all-nil struct to empty list" do
      assert PRT.encode(%PRT{}) == []
    end
  end

  describe "struct construction" do
    test "accepts keyword opts" do
      prt = %PRT{
        participation_instance_id: %HL7v2.Type.EI{entity_identifier: "1"},
        action_code: "AD",
        participation: %HL7v2.Type.CWE{identifier: "CP", text: "Collecting Provider"},
        participation_person: [%HL7v2.Type.XCN{id_number: "1234", given_name: "Jane"}]
      }

      assert prt.participation_instance_id.entity_identifier == "1"
      assert prt.action_code == "AD"
      assert prt.participation.identifier == "CP"
      assert [%HL7v2.Type.XCN{id_number: "1234", given_name: "Jane"}] = prt.participation_person
    end
  end

  describe "field validation" do
    test "missing required action_code fails typed parsing validation" do
      segment = %PRT{
        action_code: nil,
        participation: %HL7v2.Type.CWE{identifier: "CP"}
      }

      errors = FieldRules.check(segment)

      assert Enum.any?(errors, fn error ->
               error.level == :error and
                 error.location == "PRT" and
                 error.field == :action_code
             end)
    end

    test "missing required participation fails typed parsing validation" do
      segment = %PRT{action_code: "AD", participation: nil}

      errors = FieldRules.check(segment)

      assert Enum.any?(errors, fn error ->
               error.level == :error and
                 error.location == "PRT" and
                 error.field == :participation
             end)
    end

    test "both required fields populated passes field rules" do
      segment = %PRT{
        action_code: "AD",
        participation: %HL7v2.Type.CWE{identifier: "CP"}
      }

      errors = FieldRules.check(segment)

      refute Enum.any?(errors, &(&1.level == :error))
    end
  end

  describe "typed parsing integration" do
    test "parses PRT wire line in a full message" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.7\r" <>
          "EVN|A01|20260322\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|I\r" <>
          "PRT|1|AD||CP^Collecting Provider|1234^Smith^Jane||||POC^101^A|DEV001\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      prt = Enum.find(msg.segments, &is_struct(&1, PRT))

      assert %PRT{action_code: "AD"} = prt
      assert prt.participation.identifier == "CP"
      assert prt.participation.text == "Collecting Provider"
      assert [%HL7v2.Type.XCN{id_number: "1234"}] = prt.participation_person
    end
  end
end
