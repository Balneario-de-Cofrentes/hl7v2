defmodule HL7v2.Segment.VARTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.VAR

  describe "fields/0" do
    test "returns 6 field definitions" do
      assert length(VAR.fields()) == 6
    end
  end

  describe "segment_id/0" do
    test "returns VAR" do
      assert VAR.segment_id() == "VAR"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = VAR.parse([])
      assert %VAR{} = result
      assert result.variance_instance_id == nil
      assert result.documented_date_time == nil
    end

    test "parses variance data" do
      raw = [
        ["VAR001", "NS1"],
        ["20260315120000"],
        nil,
        nil,
        ["DELAY", "Delayed Treatment", "LOCAL"]
      ]

      result = VAR.parse(raw)
      assert %HL7v2.Type.EI{entity_identifier: "VAR001"} = result.variance_instance_id
      assert %HL7v2.Type.TS{} = result.documented_date_time
      assert %HL7v2.Type.CE{identifier: "DELAY"} = result.variance_classification
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [["VAR001", "NS1"], ["20260315"]]
      encoded = raw |> VAR.parse() |> VAR.encode()
      reparsed = VAR.parse(encoded)
      assert reparsed.variance_instance_id.entity_identifier == "VAR001"
    end

    test "encodes all-nil struct to empty list" do
      assert VAR.encode(%VAR{}) == []
    end
  end
end
