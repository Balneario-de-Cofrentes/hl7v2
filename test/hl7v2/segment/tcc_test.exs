defmodule HL7v2.Segment.TCCTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.TCC

  describe "fields/0" do
    test "returns 14 field definitions" do
      assert length(TCC.fields()) == 14
    end
  end

  describe "segment_id/0" do
    test "returns TCC" do
      assert TCC.segment_id() == "TCC"
    end
  end

  describe "parse/1" do
    test "parses universal_service_identifier and test_application_identifier" do
      raw = [["GLUC", "Glucose"], ["APP001", "ANALYZER"]]

      result = TCC.parse(raw)

      assert %TCC{} = result
      assert %HL7v2.Type.CE{identifier: "GLUC"} = result.universal_service_identifier
      assert %HL7v2.Type.EI{entity_identifier: "APP001"} = result.test_application_identifier
    end

    test "parses automatic_rerun_allowed" do
      raw = List.duplicate("", 8) ++ ["Y"]

      result = TCC.parse(raw)

      assert result.automatic_rerun_allowed == "Y"
    end

    test "parses empty list" do
      result = TCC.parse([])

      assert %TCC{} = result
      assert result.universal_service_identifier == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert TCC.encode(%TCC{}) == []
    end
  end
end
