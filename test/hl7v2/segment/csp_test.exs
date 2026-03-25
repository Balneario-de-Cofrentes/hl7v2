defmodule HL7v2.Segment.CSPTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.CSP

  describe "fields/0" do
    test "returns 4 field definitions" do
      assert length(CSP.fields()) == 4
    end
  end

  describe "segment_id/0" do
    test "returns CSP" do
      assert CSP.segment_id() == "CSP"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = CSP.parse([])
      assert %CSP{} = result
      assert result.study_phase_identifier == nil
    end

    test "parses clinical study phase" do
      raw = [
        ["P2", "Phase 2", "PHASES"],
        ["20260101120000"],
        ["20260630235959"],
        ["EVAL", "Evaluable", "EVAL_CODES"]
      ]

      result = CSP.parse(raw)
      assert %HL7v2.Type.CE{identifier: "P2"} = result.study_phase_identifier
      assert %HL7v2.Type.TS{} = result.date_time_study_phase_began
      assert %HL7v2.Type.TS{} = result.date_time_study_phase_ended
      assert %HL7v2.Type.CE{identifier: "EVAL"} = result.study_phase_evaluability
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [["P2", "Phase 2"], ["20260101"]]
      encoded = raw |> CSP.parse() |> CSP.encode()
      reparsed = CSP.parse(encoded)
      assert reparsed.study_phase_identifier.identifier == "P2"
    end

    test "encodes all-nil struct to empty list" do
      assert CSP.encode(%CSP{}) == []
    end
  end
end
