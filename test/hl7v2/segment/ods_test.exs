defmodule HL7v2.Segment.ODSTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.ODS

  describe "fields/0" do
    test "returns 4 field definitions" do
      assert length(ODS.fields()) == 4
    end
  end

  describe "segment_id/0" do
    test "returns ODS" do
      assert ODS.segment_id() == "ODS"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = ODS.parse([])
      assert %ODS{} = result
      assert result.type == nil
    end

    test "parses type and diet code" do
      raw = ["D", nil, ["NAS", "No Added Salt"]]
      result = ODS.parse(raw)

      assert result.type == "D"
      assert [%HL7v2.Type.CE{identifier: "NAS"}] = result.diet_supplement_or_preference_code
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["D", nil, ["NAS", "No Added Salt"]]
      encoded = raw |> ODS.parse() |> ODS.encode()
      reparsed = ODS.parse(encoded)
      assert reparsed.type == "D"
    end

    test "encodes all-nil struct to empty list" do
      assert ODS.encode(%ODS{}) == []
    end
  end
end
