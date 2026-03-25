defmodule HL7v2.Segment.NCKTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.NCK

  describe "fields/0" do
    test "returns 1 field definition" do
      assert length(NCK.fields()) == 1
    end
  end

  describe "segment_id/0" do
    test "returns NCK" do
      assert NCK.segment_id() == "NCK"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = NCK.parse([])
      assert %NCK{} = result
      assert result.system_date_time == nil
    end

    test "parses system date/time" do
      raw = [["20260326143000"]]
      result = NCK.parse(raw)
      assert %HL7v2.Type.TS{} = result.system_date_time

      assert %HL7v2.Type.DTM{year: 2026, month: 3, day: 26, hour: 14, minute: 30} =
               result.system_date_time.time
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [["20260326143000"]]
      encoded = raw |> NCK.parse() |> NCK.encode()
      reparsed = NCK.parse(encoded)
      assert %HL7v2.Type.DTM{year: 2026, month: 3, day: 26} = reparsed.system_date_time.time
    end

    test "encodes all-nil struct to empty list" do
      assert NCK.encode(%NCK{}) == []
    end
  end
end
