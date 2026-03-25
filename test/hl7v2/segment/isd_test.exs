defmodule HL7v2.Segment.ISDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.ISD

  describe "fields/0" do
    test "returns 3 field definitions" do
      assert length(ISD.fields()) == 3
    end
  end

  describe "segment_id/0" do
    test "returns ISD" do
      assert ISD.segment_id() == "ISD"
    end
  end

  describe "parse/1" do
    test "parses all fields" do
      raw = ["1", ["INIT", "Initialize"], ["ACTIVE", "Active"]]

      result = ISD.parse(raw)

      assert %ISD{} = result
      assert %HL7v2.Type.NM{value: "1"} = result.reference_interaction_number
      assert %HL7v2.Type.CE{identifier: "INIT"} = result.interaction_type_identifier
      assert %HL7v2.Type.CE{identifier: "ACTIVE"} = result.interaction_active_state
    end

    test "parses empty list" do
      result = ISD.parse([])

      assert %ISD{} = result
      assert result.reference_interaction_number == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert ISD.encode(%ISD{}) == []
    end
  end
end
