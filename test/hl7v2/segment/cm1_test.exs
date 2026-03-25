defmodule HL7v2.Segment.CM1Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.CM1

  describe "fields/0" do
    test "returns 3 field definitions" do
      assert length(CM1.fields()) == 3
    end
  end

  describe "segment_id/0" do
    test "returns CM1" do
      assert CM1.segment_id() == "CM1"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = CM1.parse([])
      assert %CM1{} = result
      assert result.set_id == nil
    end

    test "parses clinical study phase master" do
      raw = ["1", ["P2", "Phase 2", "STUDY_PHASES"], "Double-blind treatment phase"]
      result = CM1.parse(raw)
      assert result.set_id == 1
      assert %HL7v2.Type.CE{identifier: "P2", text: "Phase 2"} = result.study_phase_identifier
      assert result.description_of_study_phase == "Double-blind treatment phase"
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["1", ["P2", "Phase 2"], "Description"]
      encoded = raw |> CM1.parse() |> CM1.encode()
      reparsed = CM1.parse(encoded)
      assert reparsed.set_id == 1
      assert reparsed.study_phase_identifier.identifier == "P2"
      assert reparsed.description_of_study_phase == "Description"
    end

    test "encodes all-nil struct to empty list" do
      assert CM1.encode(%CM1{}) == []
    end
  end
end
