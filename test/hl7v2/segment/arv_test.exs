defmodule HL7v2.Segment.ARVTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.ARV

  describe "fields/0" do
    test "returns 7 field definitions" do
      assert length(ARV.fields()) == 7
    end
  end

  describe "segment_id/0" do
    test "returns ARV" do
      assert ARV.segment_id() == "ARV"
    end
  end

  describe "parse/1" do
    test "parses set_id, action_code, and access restriction value" do
      raw = ["1", "A", ["V", "VIP", "HL70717"], ["VIP", "VIP indicator", "HL70718"]]

      result = ARV.parse(raw)

      assert %ARV{} = result
      assert result.set_id == 1
      assert %HL7v2.Type.CNE{identifier: "A"} = result.access_restriction_action_code

      assert %HL7v2.Type.CWE{identifier: "V", text: "VIP", name_of_coding_system: "HL70717"} =
               result.access_restriction_value

      assert [
               %HL7v2.Type.CWE{
                 identifier: "VIP",
                 text: "VIP indicator",
                 name_of_coding_system: "HL70718"
               }
             ] = result.access_restriction_reason
    end

    test "parses empty list — all fields nil" do
      result = ARV.parse([])

      assert %ARV{} = result
      assert result.set_id == nil
      assert result.access_restriction_action_code == nil
      assert result.access_restriction_value == nil
      assert result.access_restriction_reason == nil
    end
  end

  describe "struct construction" do
    test "builds an ARV struct with named fields" do
      arv = %ARV{
        set_id: 1,
        access_restriction_action_code: %HL7v2.Type.CNE{identifier: "A"},
        access_restriction_value: %HL7v2.Type.CWE{
          identifier: "V",
          text: "VIP",
          name_of_coding_system: "HL70717"
        }
      }

      assert arv.set_id == 1
      assert arv.access_restriction_action_code.identifier == "A"
      assert arv.access_restriction_value.text == "VIP"
    end
  end

  describe "encode/1 round-trip" do
    test "parse → encode → parse preserves required fields" do
      raw = ["1", "A", ["V", "VIP", "HL70717"], ["VIP", "VIP indicator", "HL70718"]]

      encoded = raw |> ARV.parse() |> ARV.encode()
      reparsed = ARV.parse(encoded)

      assert reparsed.set_id == 1
      assert reparsed.access_restriction_action_code.identifier == "A"
      assert reparsed.access_restriction_value.identifier == "V"
      assert reparsed.access_restriction_value.text == "VIP"
      assert reparsed.access_restriction_value.name_of_coding_system == "HL70717"

      assert [%HL7v2.Type.CWE{identifier: "VIP", text: "VIP indicator"}] =
               reparsed.access_restriction_reason
    end

    test "encodes all-nil struct to empty list" do
      assert ARV.encode(%ARV{}) == []
    end
  end

  describe "typed parsing integration" do
    test "wire line ARV|1|A|V^VIP^HL70717|VIP^VIP indicator^HL70718 parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.6\r" <>
          "EVN|A01|20260322\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|I\r" <>
          "ARV|1|A|V^VIP^HL70717|VIP^VIP indicator^HL70718||\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      arv = Enum.find(msg.segments, &is_struct(&1, ARV))

      assert %ARV{set_id: 1} = arv
      assert arv.access_restriction_action_code.identifier == "A"
      assert arv.access_restriction_value.identifier == "V"
      assert arv.access_restriction_value.text == "VIP"
    end
  end
end
