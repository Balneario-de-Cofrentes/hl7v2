defmodule HL7v2.Segment.AIGTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.AIG

  describe "fields/0" do
    test "returns 14 field definitions" do
      assert length(AIG.fields()) == 14
    end
  end

  describe "segment_id/0" do
    test "returns AIG" do
      assert AIG.segment_id() == "AIG"
    end
  end

  describe "parse/1" do
    test "parses set_id and resource_type" do
      raw = ["1", "", "", ["XRAY", "X-Ray Machine", "L"]]

      result = AIG.parse(raw)

      assert %AIG{} = result
      assert result.set_id == 1
      assert %HL7v2.Type.CE{identifier: "XRAY", text: "X-Ray Machine"} = result.resource_type
    end

    test "parses segment_action_code and resource_id" do
      raw = ["1", "A", ["RES1", "Resource One"], ["EQUIP", "Equipment"]]

      result = AIG.parse(raw)

      assert result.segment_action_code == "A"
      assert %HL7v2.Type.CE{identifier: "RES1"} = result.resource_id
    end

    test "parses resource_quantity and units" do
      raw = ["1", "", "", ["EQUIP", "Equipment"], "", "2", ["EA", "Each"]]

      result = AIG.parse(raw)

      assert %HL7v2.Type.NM{value: "2"} = result.resource_quantity
      assert %HL7v2.Type.CE{identifier: "EA"} = result.resource_quantity_units
    end

    test "parses duration and start_date_time" do
      raw = [
        "1",
        "",
        "",
        ["EQUIP", "Equipment"],
        "",
        "",
        "",
        ["20260401090000"],
        "",
        "",
        "60",
        ["min", "minutes"]
      ]

      result = AIG.parse(raw)

      assert %HL7v2.Type.TS{} = result.start_date_time
      assert %HL7v2.Type.NM{value: "60"} = result.duration
      assert %HL7v2.Type.CE{identifier: "min"} = result.duration_units
    end

    test "parses allow_substitution_code and filler_status_code" do
      raw = List.duplicate("", 12) ++ ["Y", ["BOOKED", "Booked"]]

      result = AIG.parse(raw)

      assert result.allow_substitution_code == "Y"
      assert %HL7v2.Type.CE{identifier: "BOOKED"} = result.filler_status_code
    end

    test "parses empty list — all fields nil" do
      result = AIG.parse([])

      assert %AIG{} = result
      assert result.set_id == nil
      assert result.resource_type == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["1", "A", ["RES1", "Resource One"], ["EQUIP", "Equipment"]]

      encoded = raw |> AIG.parse() |> AIG.encode()
      reparsed = AIG.parse(encoded)

      assert reparsed.set_id == 1
      assert reparsed.segment_action_code == "A"
      assert reparsed.resource_id.identifier == "RES1"
      assert reparsed.resource_type.identifier == "EQUIP"
    end

    test "trailing nil fields trimmed" do
      aig = %AIG{
        set_id: 1,
        resource_type: %HL7v2.Type.CE{identifier: "EQUIP"}
      }

      encoded = AIG.encode(aig)

      assert length(encoded) == 4
    end

    test "encodes all-nil struct to empty list" do
      assert AIG.encode(%AIG{}) == []
    end
  end

  describe "typed parsing integration" do
    test "SIU^S12 with AIG parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||SIU^S12^SIU_S12|1|P|2.5.1\r" <>
          "SCH|1||||||||30^MIN\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "RGS|1\r" <>
          "AIG|1||RES1^Resource One|EQUIP^Equipment\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      aig = Enum.find(msg.segments, &is_struct(&1, AIG))
      assert %AIG{set_id: 1} = aig
      assert aig.resource_type.identifier == "EQUIP"
    end
  end
end
