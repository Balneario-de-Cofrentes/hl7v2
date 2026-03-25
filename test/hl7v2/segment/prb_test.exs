defmodule HL7v2.Segment.PRBTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.PRB

  describe "fields/0" do
    test "returns 25 field definitions" do
      assert length(PRB.fields()) == 25
    end
  end

  describe "segment_id/0" do
    test "returns PRB" do
      assert PRB.segment_id() == "PRB"
    end
  end

  describe "parse/1" do
    test "parses action_code and problem_id" do
      raw = ["AD", ["20260301"], ["DM2", "Type 2 Diabetes"]]

      result = PRB.parse(raw)

      assert %PRB{} = result
      assert result.action_code == "AD"
      assert %HL7v2.Type.CE{identifier: "DM2"} = result.problem_id
    end

    test "parses empty list" do
      result = PRB.parse([])

      assert %PRB{} = result
      assert result.action_code == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert PRB.encode(%PRB{}) == []
    end
  end
end
