defmodule HL7v2.Segment.AILTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.AIL

  describe "fields/0" do
    test "returns 12 field definitions" do
      assert length(AIL.fields()) == 12
    end
  end

  describe "segment_id/0" do
    test "returns AIL" do
      assert AIL.segment_id() == "AIL"
    end
  end

  describe "parse/1" do
    test "parses set_id and location_type" do
      raw = ["1", "", "", ["CLINIC", "Clinic Room"]]

      result = AIL.parse(raw)

      assert %AIL{} = result
      assert result.set_id == 1
      assert %HL7v2.Type.CE{identifier: "CLINIC"} = result.location_type
    end

    test "parses segment_action_code" do
      raw = ["1", "A"]

      result = AIL.parse(raw)

      assert result.segment_action_code == "A"
    end

    test "parses location_resource_id as PL" do
      raw = ["1", "", [["ROOM1", "FLOOR2", "BED3"]]]

      result = AIL.parse(raw)

      assert [%HL7v2.Type.PL{point_of_care: "ROOM1"}] = result.location_resource_id
    end

    test "parses duration and start_date_time" do
      raw = [
        "1",
        "",
        "",
        "",
        "",
        ["20260401090000"],
        "",
        "",
        "30",
        ["min", "minutes"]
      ]

      result = AIL.parse(raw)

      assert %HL7v2.Type.TS{} = result.start_date_time
      assert %HL7v2.Type.NM{value: "30"} = result.duration
      assert %HL7v2.Type.CE{identifier: "min"} = result.duration_units
    end

    test "parses allow_substitution_code and filler_status_code" do
      raw = List.duplicate("", 10) ++ ["N", ["BOOKED", "Booked"]]

      result = AIL.parse(raw)

      assert result.allow_substitution_code == "N"
      assert %HL7v2.Type.CE{identifier: "BOOKED"} = result.filler_status_code
    end

    test "parses empty list — all fields nil" do
      result = AIL.parse([])

      assert %AIL{} = result
      assert result.set_id == nil
      assert result.location_type == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["1", "A", "", ["CLINIC", "Clinic Room"]]

      encoded = raw |> AIL.parse() |> AIL.encode()
      reparsed = AIL.parse(encoded)

      assert reparsed.set_id == 1
      assert reparsed.segment_action_code == "A"
      assert reparsed.location_type.identifier == "CLINIC"
    end

    test "trailing nil fields trimmed" do
      ail = %AIL{set_id: 1}

      encoded = AIL.encode(ail)

      assert length(encoded) == 1
    end

    test "encodes all-nil struct to empty list" do
      assert AIL.encode(%AIL{}) == []
    end
  end

  describe "typed parsing integration" do
    test "SIU^S12 with AIL parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||SIU^S12^SIU_S12|1|P|2.5.1\r" <>
          "SCH|1||||||||30^MIN\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "RGS|1\r" <>
          "AIL|1||ROOM1^^BED3|CLINIC^Clinic Room\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      ail = Enum.find(msg.segments, &is_struct(&1, AIL))
      assert %AIL{set_id: 1} = ail
    end
  end
end
