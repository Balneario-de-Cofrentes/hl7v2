defmodule HL7v2.Segment.NSTTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.NST

  describe "fields/0" do
    test "returns 15 field definitions" do
      assert length(NST.fields()) == 15
    end
  end

  describe "segment_id/0" do
    test "returns NST" do
      assert NST.segment_id() == "NST"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = NST.parse([])
      assert %NST{} = result
      assert result.statistics_available == nil
    end

    test "parses statistics fields" do
      raw = [
        "Y",
        "APP1",
        "I",
        ["20260326120000"],
        ["20260326130000"],
        "50000",
        "45000",
        "100",
        "95",
        "2",
        "1",
        "3",
        "0",
        "1",
        "5"
      ]

      result = NST.parse(raw)

      assert result.statistics_available == "Y"
      assert result.source_identifier == "APP1"
      assert result.source_type == "I"
      assert %HL7v2.Type.NM{value: "50000"} = result.receive_character_count
      assert %HL7v2.Type.NM{value: "100"} = result.messages_received
      assert %HL7v2.Type.NM{value: "5"} = result.application_control_level_errors
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["Y", "APP1", "I"]
      encoded = raw |> NST.parse() |> NST.encode()
      reparsed = NST.parse(encoded)
      assert reparsed.statistics_available == "Y"
      assert reparsed.source_identifier == "APP1"
    end

    test "encodes all-nil struct to empty list" do
      assert NST.encode(%NST{}) == []
    end
  end
end
