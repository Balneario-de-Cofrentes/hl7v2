defmodule HL7v2.Segment.CM2Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.CM2

  describe "fields/0" do
    test "returns 4 field definitions" do
      assert length(CM2.fields()) == 4
    end
  end

  describe "segment_id/0" do
    test "returns CM2" do
      assert CM2.segment_id() == "CM2"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = CM2.parse([])
      assert %CM2{} = result
      assert result.set_id == nil
    end

    test "parses clinical study schedule master" do
      raw = ["1", ["TP1", "Baseline Visit", "TIMEPOINTS"], "Initial assessment", "3"]
      result = CM2.parse(raw)
      assert result.set_id == 1
      assert %HL7v2.Type.CE{identifier: "TP1"} = result.scheduled_time_point
      assert result.description_of_time_point == "Initial assessment"
      assert %HL7v2.Type.NM{value: "3"} = result.number_of_sample_containers
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["1", ["TP1", "Baseline"], "Description", "2"]
      encoded = raw |> CM2.parse() |> CM2.encode()
      reparsed = CM2.parse(encoded)
      assert reparsed.set_id == 1
      assert reparsed.scheduled_time_point.identifier == "TP1"
      assert %HL7v2.Type.NM{value: "2"} = reparsed.number_of_sample_containers
    end

    test "encodes all-nil struct to empty list" do
      assert CM2.encode(%CM2{}) == []
    end
  end
end
