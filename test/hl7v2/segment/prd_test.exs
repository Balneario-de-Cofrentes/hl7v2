defmodule HL7v2.Segment.PRDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.PRD

  describe "fields/0" do
    test "returns 9 field definitions" do
      assert length(PRD.fields()) == 9
    end
  end

  describe "segment_id/0" do
    test "returns PRD" do
      assert PRD.segment_id() == "PRD"
    end
  end

  describe "parse/1" do
    test "parses provider_role as repeating CE" do
      raw = [[["RP", "Referring Provider"]]]

      result = PRD.parse(raw)

      assert %PRD{} = result
      assert [%HL7v2.Type.CE{identifier: "RP"}] = result.provider_role
    end

    test "parses empty list" do
      result = PRD.parse([])

      assert %PRD{} = result
      assert result.provider_role == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert PRD.encode(%PRD{}) == []
    end
  end
end
