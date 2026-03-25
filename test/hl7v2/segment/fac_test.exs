defmodule HL7v2.Segment.FACTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.FAC

  describe "fields/0" do
    test "returns 12 field definitions" do
      assert length(FAC.fields()) == 12
    end
  end

  describe "segment_id/0" do
    test "returns FAC" do
      assert FAC.segment_id() == "FAC"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = FAC.parse([])
      assert %FAC{} = result
      assert result.facility_id == nil
    end

    test "parses facility data" do
      raw = [
        ["FAC001", "HOSP_NS"],
        "M"
      ]

      result = FAC.parse(raw)
      assert %HL7v2.Type.EI{entity_identifier: "FAC001"} = result.facility_id
      assert result.facility_type == "M"
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [["FAC001", "NS"], "M"]
      encoded = raw |> FAC.parse() |> FAC.encode()
      reparsed = FAC.parse(encoded)
      assert reparsed.facility_id.entity_identifier == "FAC001"
      assert reparsed.facility_type == "M"
    end

    test "encodes all-nil struct to empty list" do
      assert FAC.encode(%FAC{}) == []
    end
  end
end
