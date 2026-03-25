defmodule HL7v2.Segment.CM0Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.CM0

  describe "fields/0" do
    test "returns 11 field definitions" do
      assert length(CM0.fields()) == 11
    end
  end

  describe "segment_id/0" do
    test "returns CM0" do
      assert CM0.segment_id() == "CM0"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = CM0.parse([])
      assert %CM0{} = result
      assert result.set_id == nil
      assert result.sponsor_study_id == nil
    end

    test "parses clinical study master" do
      raw = [
        "1",
        ["STUDY001", "SPONSOR_NS"],
        nil,
        "Phase 2 Trial of Drug X",
        nil,
        "20260115",
        "42"
      ]

      result = CM0.parse(raw)
      assert result.set_id == 1
      assert %HL7v2.Type.EI{entity_identifier: "STUDY001"} = result.sponsor_study_id
      assert result.title_of_study == "Phase 2 Trial of Drug X"
      assert %HL7v2.Type.NM{value: "42"} = result.total_accrual_to_date
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["1", ["STUDY001", "SPONSOR"], nil, "Study Title"]
      encoded = raw |> CM0.parse() |> CM0.encode()
      reparsed = CM0.parse(encoded)
      assert reparsed.set_id == 1
      assert reparsed.sponsor_study_id.entity_identifier == "STUDY001"
      assert reparsed.title_of_study == "Study Title"
    end

    test "encodes all-nil struct to empty list" do
      assert CM0.encode(%CM0{}) == []
    end
  end
end
