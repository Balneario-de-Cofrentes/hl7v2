defmodule HL7v2.Segment.SCHTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.SCH
  alias HL7v2.Type.{CE, EI, PL}

  describe "field count" do
    test "defines 27 fields" do
      assert length(SCH.fields()) == 27
    end
  end

  describe "parse/1" do
    test "parses appointment info" do
      raw = [
        ["APT001", "PLACER"],
        ["APT001", "FILLER"],
        nil,
        nil,
        nil,
        ["ROUTINE", "Routine Visit"]
      ]

      sch = SCH.parse(raw)

      assert %EI{entity_identifier: "APT001", namespace_id: "PLACER"} = sch.placer_appointment_id
      assert %EI{entity_identifier: "APT001", namespace_id: "FILLER"} = sch.filler_appointment_id
      assert %CE{identifier: "ROUTINE", text: "Routine Visit"} = sch.event_reason
    end

    test "parses appointment with duration and type" do
      raw = [
        ["APT001", "PLACER"],
        nil,
        nil,
        nil,
        nil,
        ["ROUTINE", "Routine Visit"],
        ["CHECKUP", "Annual Checkup"],
        ["FOLLOW", "Follow-up"],
        "30",
        ["MIN", "Minutes"]
      ]

      sch = SCH.parse(raw)

      assert %HL7v2.Type.NM{value: "30", original: "30"} = sch.appointment_duration
      assert %CE{identifier: "MIN", text: "Minutes"} = sch.appointment_duration_units
      assert %CE{identifier: "CHECKUP", text: "Annual Checkup"} = sch.appointment_reason
      assert %CE{identifier: "FOLLOW", text: "Follow-up"} = sch.appointment_type
    end

    test "parses placer contact location" do
      # placer_contact_location is at seq 15
      raw = List.duplicate(nil, 14) ++ [["CLINIC", "200", "B"]]

      sch = SCH.parse(raw)

      assert %PL{point_of_care: "CLINIC", room: "200", bed: "B"} = sch.placer_contact_location
    end

    test "returns nil for missing optional fields" do
      sch = SCH.parse([])

      assert sch.placer_appointment_id == nil
      assert sch.filler_appointment_id == nil
      assert sch.event_reason == nil
      assert sch.appointment_duration == nil
    end

    test "parses empty list" do
      sch = SCH.parse([])

      assert %SCH{} = sch
    end
  end

  describe "encode/1" do
    test "encodes SCH with appointment info" do
      sch = %SCH{
        placer_appointment_id: %EI{entity_identifier: "APT001", namespace_id: "PLACER"},
        filler_appointment_id: %EI{entity_identifier: "APT001", namespace_id: "FILLER"},
        event_reason: %CE{identifier: "ROUTINE", text: "Routine Visit"}
      }

      encoded = SCH.encode(sch)

      assert Enum.at(encoded, 0) == ["APT001", "PLACER"]
      assert Enum.at(encoded, 1) == ["APT001", "FILLER"]
      assert Enum.at(encoded, 5) == ["ROUTINE", "Routine Visit"]
    end

    test "encodes nil segment fields" do
      sch = %SCH{}
      encoded = SCH.encode(sch)

      assert encoded == []
    end
  end

  describe "round-trip" do
    test "parse then encode preserves appointment data" do
      raw = [
        ["APT001", "PLACER"],
        ["APT001", "FILLER"],
        nil,
        nil,
        nil,
        ["ROUTINE", "Routine Visit"]
      ]

      result = raw |> SCH.parse() |> SCH.encode()

      assert Enum.at(result, 0) == ["APT001", "PLACER"]
      assert Enum.at(result, 1) == ["APT001", "FILLER"]
      assert Enum.at(result, 5) == ["ROUTINE", "Routine Visit"]
    end
  end
end
