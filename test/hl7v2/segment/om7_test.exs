defmodule HL7v2.Segment.OM7Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.OM7

  describe "fields/0" do
    test "returns 24 field definitions" do
      assert length(OM7.fields()) == 24
    end
  end

  describe "segment_id/0" do
    test "returns OM7" do
      assert OM7.segment_id() == "OM7"
    end
  end

  describe "parse/1" do
    test "parses sequence and service identifier" do
      raw = ["1", ["GLUC", "Glucose"]]

      result = OM7.parse(raw)

      assert %OM7{} = result
      assert %HL7v2.Type.CE{identifier: "GLUC"} = result.universal_service_identifier
    end

    test "parses empty list" do
      result = OM7.parse([])

      assert %OM7{} = result
      assert result.sequence_number == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert OM7.encode(%OM7{}) == []
    end
  end
end
