defmodule HL7v2.Segment.SACTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.SAC

  describe "fields/0" do
    test "returns 44 field definitions" do
      assert length(SAC.fields()) == 44
    end
  end

  describe "segment_id/0" do
    test "returns SAC" do
      assert SAC.segment_id() == "SAC"
    end
  end

  describe "parse/1" do
    test "parses external_accession_identifier" do
      raw = [["ACC001", "LAB"]]

      result = SAC.parse(raw)

      assert %SAC{} = result
      assert %HL7v2.Type.EI{entity_identifier: "ACC001"} = result.external_accession_identifier
    end

    test "parses container_status" do
      raw = List.duplicate("", 7) ++ [["I", "Identified"]]

      result = SAC.parse(raw)

      assert %HL7v2.Type.CE{identifier: "I"} = result.container_status
    end

    test "parses empty list" do
      result = SAC.parse([])

      assert %SAC{} = result
      assert result.external_accession_identifier == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert SAC.encode(%SAC{}) == []
    end
  end
end
