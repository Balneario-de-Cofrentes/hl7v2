defmodule HL7v2.Segment.CSSTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.CSS

  describe "fields/0" do
    test "returns 3 field definitions" do
      assert length(CSS.fields()) == 3
    end
  end

  describe "segment_id/0" do
    test "returns CSS" do
      assert CSS.segment_id() == "CSS"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = CSS.parse([])
      assert %CSS{} = result
      assert result.study_scheduled_time_point == nil
    end

    test "parses clinical study data schedule" do
      raw = [
        ["TP1", "Baseline", "TIMEPOINTS"],
        ["20260315"],
        nil
      ]

      result = CSS.parse(raw)
      assert %HL7v2.Type.CE{identifier: "TP1"} = result.study_scheduled_time_point
      assert %HL7v2.Type.TS{} = result.study_scheduled_patient_time_point
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [["TP1", "Baseline"], ["20260315"]]
      encoded = raw |> CSS.parse() |> CSS.encode()
      reparsed = CSS.parse(encoded)
      assert reparsed.study_scheduled_time_point.identifier == "TP1"
    end

    test "encodes all-nil struct to empty list" do
      assert CSS.encode(%CSS{}) == []
    end
  end
end
