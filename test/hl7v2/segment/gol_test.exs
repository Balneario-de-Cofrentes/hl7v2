defmodule HL7v2.Segment.GOLTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.GOL

  describe "fields/0" do
    test "returns 21 field definitions" do
      assert length(GOL.fields()) == 21
    end
  end

  describe "segment_id/0" do
    test "returns GOL" do
      assert GOL.segment_id() == "GOL"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = GOL.parse([])
      assert %GOL{} = result
      assert result.action_code == nil
    end

    test "parses goal detail" do
      raw = [
        "AD",
        ["20260315"],
        ["GOAL001", "Improve mobility", "GOALS"],
        ["G001", "NS1"],
        nil,
        "1"
      ]

      result = GOL.parse(raw)
      assert result.action_code == "AD"
      assert %HL7v2.Type.TS{} = result.action_date_time
      assert %HL7v2.Type.CE{identifier: "GOAL001"} = result.goal_id
      assert %HL7v2.Type.EI{entity_identifier: "G001"} = result.goal_instance_id
      assert %HL7v2.Type.NM{value: "1"} = result.goal_list_priority
    end

    test "preserves raw trailing fields" do
      raw = List.duplicate(nil, 15) ++ ["raw_16"]
      result = GOL.parse(raw)
      assert result.field_16 == "raw_16"
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["AD", ["20260315"], ["GOAL001", "Mobility"], ["G001", "NS1"]]
      encoded = raw |> GOL.parse() |> GOL.encode()
      reparsed = GOL.parse(encoded)
      assert reparsed.action_code == "AD"
      assert reparsed.goal_id.identifier == "GOAL001"
    end

    test "encodes all-nil struct to empty list" do
      assert GOL.encode(%GOL{}) == []
    end
  end
end
