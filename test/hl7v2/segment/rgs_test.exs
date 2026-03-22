defmodule HL7v2.Segment.RGSTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.RGS
  alias HL7v2.Type.CE

  describe "parse/1" do
    test "parses RGS with set_id" do
      raw = ["1"]
      rgs = RGS.parse(raw)
      assert %RGS{} = rgs
      assert rgs.set_id == 1
    end

    test "parses RGS with action code and resource group" do
      raw = ["1", "A", ["GRP1", "Group One"]]
      rgs = RGS.parse(raw)
      assert rgs.set_id == 1
      assert rgs.segment_action_code == "A"
      assert %CE{identifier: "GRP1"} = rgs.resource_group_id
    end

    test "parses minimal RGS" do
      raw = ["1"]
      rgs = RGS.parse(raw)
      assert rgs.segment_action_code == nil
      assert rgs.resource_group_id == nil
    end
  end

  describe "encode/1" do
    test "encodes RGS struct" do
      rgs = %RGS{set_id: 1, segment_action_code: "A"}
      encoded = RGS.encode(rgs)
      assert is_list(encoded)
    end

    test "round-trip preserves data" do
      raw = ["1", "A", ["GRP1", "Group One"]]
      rgs = RGS.parse(raw)
      encoded = RGS.encode(rgs)
      reparsed = RGS.parse(encoded)

      assert reparsed.set_id == rgs.set_id
      assert reparsed.segment_action_code == rgs.segment_action_code
      assert reparsed.resource_group_id == rgs.resource_group_id
    end
  end

  describe "segment metadata" do
    test "segment_id is RGS" do
      assert RGS.segment_id() == "RGS"
    end

    test "has 3 fields" do
      assert length(RGS.fields()) == 3
    end
  end

  describe "typed parsing integration" do
    test "SIU^S12 with RGS parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||SIU^S12^SIU_S12|1|P|2.5.1\r" <>
          "SCH|1||||||||30^MIN\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "RGS|1\r" <>
          "AIS|1||99213^Office Visit^CPT\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      rgs = Enum.find(msg.segments, &is_struct(&1, RGS))
      assert %RGS{set_id: 1} = rgs
    end
  end
end
