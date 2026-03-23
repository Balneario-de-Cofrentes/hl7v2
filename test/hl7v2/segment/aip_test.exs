defmodule HL7v2.Segment.AIPTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.AIP

  describe "fields/0" do
    test "returns 12 field definitions" do
      assert length(AIP.fields()) == 12
    end
  end

  describe "segment_id/0" do
    test "returns AIP" do
      assert AIP.segment_id() == "AIP"
    end
  end

  describe "parse/1" do
    test "parses set_id and resource_type" do
      raw = ["1", "", "", ["PHYS", "Physician"]]

      result = AIP.parse(raw)

      assert %AIP{} = result
      assert result.set_id == 1
      assert %HL7v2.Type.CE{identifier: "PHYS"} = result.resource_type
    end

    test "parses segment_action_code" do
      raw = ["1", "A"]

      result = AIP.parse(raw)

      assert result.segment_action_code == "A"
    end

    test "parses personnel_resource_id as repeating XCN" do
      raw = ["1", "", [["12345", "Smith", "John"]]]

      result = AIP.parse(raw)

      assert [%HL7v2.Type.XCN{id_number: "12345"}] = result.personnel_resource_id
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
        "60",
        ["min", "minutes"]
      ]

      result = AIP.parse(raw)

      assert %HL7v2.Type.TS{} = result.start_date_time
      assert %HL7v2.Type.NM{value: "60"} = result.duration
      assert %HL7v2.Type.CE{identifier: "min"} = result.duration_units
    end

    test "parses allow_substitution_code and filler_status_code" do
      raw = List.duplicate("", 10) ++ ["Y", ["BOOKED", "Booked"]]

      result = AIP.parse(raw)

      assert result.allow_substitution_code == "Y"
      assert %HL7v2.Type.CE{identifier: "BOOKED"} = result.filler_status_code
    end

    test "parses empty list — all fields nil" do
      result = AIP.parse([])

      assert %AIP{} = result
      assert result.set_id == nil
      assert result.resource_type == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["1", "A", "", ["PHYS", "Physician"]]

      encoded = raw |> AIP.parse() |> AIP.encode()
      reparsed = AIP.parse(encoded)

      assert reparsed.set_id == 1
      assert reparsed.segment_action_code == "A"
      assert reparsed.resource_type.identifier == "PHYS"
    end

    test "trailing nil fields trimmed" do
      aip = %AIP{set_id: 1}

      encoded = AIP.encode(aip)

      assert length(encoded) == 1
    end

    test "encodes all-nil struct to empty list" do
      assert AIP.encode(%AIP{}) == []
    end
  end

  describe "typed parsing integration" do
    test "SIU^S12 with AIP parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||SIU^S12^SIU_S12|1|P|2.5.1\r" <>
          "SCH|1||||||||30^MIN\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "RGS|1\r" <>
          "AIP|1||12345^Smith^John|PHYS^Physician\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      aip = Enum.find(msg.segments, &is_struct(&1, AIP))
      assert %AIP{set_id: 1} = aip
    end
  end
end
