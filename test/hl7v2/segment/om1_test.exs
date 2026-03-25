defmodule HL7v2.Segment.OM1Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.OM1

  describe "fields/0" do
    test "returns 47 field definitions" do
      assert length(OM1.fields()) == 47
    end
  end

  describe "segment_id/0" do
    test "returns OM1" do
      assert OM1.segment_id() == "OM1"
    end
  end

  describe "parse/1" do
    test "parses sequence_number and producer_id" do
      raw = ["1", ["GLUC", "Glucose"], "", "", ["LABCORP", "LabCorp"]]

      result = OM1.parse(raw)

      assert %OM1{} = result
      assert %HL7v2.Type.NM{value: "1"} = result.sequence_number
      assert %HL7v2.Type.CE{identifier: "GLUC"} = result.producers_service_test_observation_id
      assert %HL7v2.Type.CE{identifier: "LABCORP"} = result.producer_id
    end

    test "parses empty list" do
      result = OM1.parse([])

      assert %OM1{} = result
      assert result.sequence_number == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert OM1.encode(%OM1{}) == []
    end
  end
end
