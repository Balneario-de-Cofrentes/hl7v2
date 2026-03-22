defmodule HL7v2.Segment.ACCTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.ACC

  describe "fields/0" do
    test "returns 11 field definitions" do
      assert length(ACC.fields()) == 11
    end
  end

  describe "segment_id/0" do
    test "returns ACC" do
      assert ACC.segment_id() == "ACC"
    end
  end

  describe "parse/1" do
    test "parses accident_date_time and accident_code" do
      raw = [["20260315140000"], ["AUTO", "Auto Accident", "HL70050"]]

      result = ACC.parse(raw)

      assert %ACC{} = result

      assert %HL7v2.Type.TS{
               time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 15, hour: 14}
             } = result.accident_date_time

      assert %HL7v2.Type.CE{identifier: "AUTO", text: "Auto Accident"} = result.accident_code
    end

    test "parses accident_location" do
      raw = [["20260315"], "", "Highway 101"]

      result = ACC.parse(raw)

      assert result.accident_location == "Highway 101"
    end

    test "parses auto_accident_state" do
      raw = ["", "", "", ["CA", "California"]]

      result = ACC.parse(raw)

      assert %HL7v2.Type.CE{identifier: "CA", text: "California"} = result.auto_accident_state
    end

    test "parses indicator fields" do
      raw = ["", "", "", "", "Y", "N"]

      result = ACC.parse(raw)

      assert result.accident_job_related_indicator == "Y"
      assert result.accident_death_indicator == "N"
    end

    test "parses entered_by as XCN" do
      raw = List.duplicate("", 6) ++ [["12345", "Smith", "John"]]

      result = ACC.parse(raw)

      assert %HL7v2.Type.XCN{id_number: "12345"} = result.entered_by
    end

    test "parses description and brought_in_by" do
      raw = List.duplicate("", 7) ++ ["Head-on collision", "Ambulance"]

      result = ACC.parse(raw)

      assert result.accident_description == "Head-on collision"
      assert result.brought_in_by == "Ambulance"
    end

    test "parses police_notified and accident_address" do
      raw =
        List.duplicate("", 9) ++
          ["Y", ["123 Main St", "", "", "Springfield", "IL", "62701"]]

      result = ACC.parse(raw)

      assert result.police_notified_indicator == "Y"

      assert %HL7v2.Type.XAD{
               street_address: %HL7v2.Type.SAD{street_or_mailing_address: "123 Main St"}
             } = result.accident_address
    end

    test "parses empty list — all fields nil" do
      result = ACC.parse([])

      assert %ACC{} = result
      assert result.accident_date_time == nil
      assert result.accident_code == nil
      assert result.accident_location == nil
      assert result.accident_address == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [["20260315140000"], ["AUTO", "Auto Accident"], "Highway 101"]

      encoded = raw |> ACC.parse() |> ACC.encode()
      reparsed = ACC.parse(encoded)

      assert reparsed.accident_code.identifier == "AUTO"
      assert reparsed.accident_location == "Highway 101"
    end

    test "trailing nil fields trimmed" do
      acc = %ACC{accident_location: "Highway 101"}

      encoded = ACC.encode(acc)

      assert length(encoded) == 3
    end

    test "encodes all-nil struct to empty list" do
      assert ACC.encode(%ACC{}) == []
    end
  end

  describe "typed parsing integration" do
    test "ADT^A01 with ACC parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.5.1\r" <>
          "EVN|A01|20260322\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|I\r" <>
          "ACC|20260315140000|AUTO^Auto Accident|Highway 101\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      acc = Enum.find(msg.segments, &is_struct(&1, ACC))
      assert %ACC{accident_location: "Highway 101"} = acc
    end
  end
end
