defmodule HL7v2.Segment.EVNTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.EVN

  describe "fields/0" do
    test "returns 7 field definitions" do
      assert length(EVN.fields()) == 7
    end
  end

  describe "segment_id/0" do
    test "returns EVN" do
      assert EVN.segment_id() == "EVN"
    end
  end

  describe "parse/1" do
    test "parses recorded_date_time as TS" do
      raw = ["", ["20260322120000"]]

      result = EVN.parse(raw)

      assert %EVN{} = result
      assert result.event_type_code == nil

      assert %HL7v2.Type.TS{
               time: %HL7v2.Type.DTM{
                 year: 2026,
                 month: 3,
                 day: 22,
                 hour: 12,
                 minute: 0,
                 second: 0
               }
             } = result.recorded_date_time
    end

    test "parses event_type_code and event_reason_code" do
      raw = ["A01", ["20260322120000"], "", "01"]

      result = EVN.parse(raw)

      assert result.event_type_code == "A01"
      assert result.event_reason_code == "01"
    end

    test "parses event_facility as HD" do
      raw = ["", ["20260322120000"], "", "", "", "", ["HOSP", "2.16.840.1.113883", "ISO"]]

      result = EVN.parse(raw)

      assert %HL7v2.Type.HD{
               namespace_id: "HOSP",
               universal_id: "2.16.840.1.113883",
               universal_id_type: "ISO"
             } = result.event_facility
    end

    test "operator_id (raw type) is preserved as-is" do
      operator_data = [["SMITH", "JOHN"]]
      raw = ["", ["20260322120000"], "", "", operator_data]

      result = EVN.parse(raw)

      assert result.operator_id == operator_data
    end

    test "parses event_occurred as TS" do
      raw = ["", ["20260322120000"], ["20260323080000"], "", "", ["20260322115500"]]

      result = EVN.parse(raw)

      assert %HL7v2.Type.TS{
               time: %HL7v2.Type.DTM{
                 year: 2026,
                 month: 3,
                 day: 22,
                 hour: 11,
                 minute: 55,
                 second: 0
               }
             } = result.event_occurred
    end

    test "parses empty list — all fields nil" do
      result = EVN.parse([])

      assert %EVN{} = result
      assert result.event_type_code == nil
      assert result.recorded_date_time == nil
      assert result.date_time_planned_event == nil
      assert result.event_reason_code == nil
      assert result.operator_id == nil
      assert result.event_occurred == nil
      assert result.event_facility == nil
    end
  end

  describe "encode/1" do
    test "round-trip: parse then encode" do
      raw = ["A01", ["20260322120000"], "", "01"]

      encoded = raw |> EVN.parse() |> EVN.encode()

      assert Enum.at(encoded, 0) == "A01"
      assert Enum.at(encoded, 1) == ["20260322120000"]
      assert Enum.at(encoded, 3) == "01"
    end

    test "round-trip with event_facility" do
      raw = ["", ["20260322120000"], "", "", "", "", ["HOSP", "2.16.840.1.113883", "ISO"]]

      encoded = raw |> EVN.parse() |> EVN.encode()

      assert List.last(encoded) == ["HOSP", "2.16.840.1.113883", "ISO"]
    end

    test "raw operator_id survives round-trip" do
      operator_data = "SMITH"
      raw = ["", ["20260322120000"], "", "", operator_data]

      encoded = raw |> EVN.parse() |> EVN.encode()

      assert Enum.at(encoded, 4) == operator_data
    end

    test "trailing nil fields trimmed" do
      evn = %EVN{event_type_code: "A01"}

      encoded = EVN.encode(evn)

      assert encoded == ["A01"]
    end

    test "encodes all-nil struct to empty list" do
      assert EVN.encode(%EVN{}) == []
    end
  end
end
