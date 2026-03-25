defmodule HL7v2.Segment.RCPTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.RCP

  describe "fields/0" do
    test "returns 7 field definitions" do
      assert length(RCP.fields()) == 7
    end
  end

  describe "segment_id/0" do
    test "returns RCP" do
      assert RCP.segment_id() == "RCP"
    end
  end

  describe "parse/1" do
    test "parses query_priority and quantity" do
      raw = ["I", ["25", ["RD", "records"]]]

      result = RCP.parse(raw)

      assert %RCP{} = result
      assert result.query_priority == "I"
      assert %HL7v2.Type.CQ{quantity: "25"} = result.quantity_limited_request
    end

    test "parses empty list" do
      result = RCP.parse([])

      assert %RCP{} = result
      assert result.query_priority == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert RCP.encode(%RCP{}) == []
    end
  end
end
