defmodule HL7v2.Segment.NDSTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.NDS

  describe "fields/0" do
    test "returns 4 field definitions" do
      assert length(NDS.fields()) == 4
    end
  end

  describe "segment_id/0" do
    test "returns NDS" do
      assert NDS.segment_id() == "NDS"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = NDS.parse([])
      assert %NDS{} = result
      assert result.notification_reference_number == nil
    end

    test "parses all fields" do
      raw = ["1", ["20260326140000"], "2", ["E001", "Equipment malfunction"]]
      result = NDS.parse(raw)

      assert %HL7v2.Type.NM{value: "1"} = result.notification_reference_number
      assert %HL7v2.Type.TS{} = result.notification_date_time

      assert %HL7v2.Type.DTM{year: 2026, month: 3, day: 26, hour: 14} =
               result.notification_date_time.time

      assert %HL7v2.Type.NM{value: "2"} = result.notification_alert_severity
      assert %HL7v2.Type.CE{identifier: "E001"} = result.notification_code
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["1", ["20260326140000"], "2", ["E001", "Equipment malfunction"]]
      encoded = raw |> NDS.parse() |> NDS.encode()
      reparsed = NDS.parse(encoded)
      assert reparsed.notification_reference_number.value == "1"
      assert reparsed.notification_code.identifier == "E001"
    end

    test "encodes all-nil struct to empty list" do
      assert NDS.encode(%NDS{}) == []
    end
  end
end
