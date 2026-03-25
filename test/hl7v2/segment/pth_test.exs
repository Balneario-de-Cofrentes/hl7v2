defmodule HL7v2.Segment.PTHTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.PTH

  describe "fields/0" do
    test "returns 6 field definitions" do
      assert length(PTH.fields()) == 6
    end
  end

  describe "segment_id/0" do
    test "returns PTH" do
      assert PTH.segment_id() == "PTH"
    end
  end

  describe "parse/1" do
    test "parses action_code and pathway_id" do
      raw = ["AD", ["CHF", "CHF Clinical Pathway"]]

      result = PTH.parse(raw)

      assert %PTH{} = result
      assert result.action_code == "AD"
      assert %HL7v2.Type.CE{identifier: "CHF"} = result.pathway_id
    end

    test "parses pathway_instance_id" do
      raw = ["AD", ["CHF"], ["PTH001", "HOSP"]]

      result = PTH.parse(raw)

      assert %HL7v2.Type.EI{entity_identifier: "PTH001"} = result.pathway_instance_id
    end

    test "parses empty list" do
      result = PTH.parse([])

      assert %PTH{} = result
      assert result.action_code == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert PTH.encode(%PTH{}) == []
    end

    test "round-trip preserves data" do
      raw = ["AD", ["CHF", "CHF Clinical Pathway"]]

      encoded = raw |> PTH.parse() |> PTH.encode()

      assert Enum.at(encoded, 0) == "AD"
      assert Enum.at(encoded, 1) == ["CHF", "CHF Clinical Pathway"]
    end
  end
end
