defmodule HL7v2.Segment.ERQTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.ERQ

  describe "fields/0" do
    test "returns 3 field definitions" do
      assert length(ERQ.fields()) == 3
    end
  end

  describe "segment_id/0" do
    test "returns ERQ" do
      assert ERQ.segment_id() == "ERQ"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = ERQ.parse([])
      assert %ERQ{} = result
      assert result.query_tag == nil
      assert result.event_identifier == nil
    end

    test "parses query tag and event identifier" do
      raw = ["TAG1", ["A01", "ADT/ACK - Admit/Visit Notification"]]
      result = ERQ.parse(raw)

      assert result.query_tag == "TAG1"
      assert %HL7v2.Type.CE{identifier: "A01"} = result.event_identifier
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["TAG1", ["A01", "ADT"]]
      encoded = raw |> ERQ.parse() |> ERQ.encode()
      reparsed = ERQ.parse(encoded)
      assert reparsed.query_tag == "TAG1"
      assert reparsed.event_identifier.identifier == "A01"
    end

    test "encodes all-nil struct to empty list" do
      assert ERQ.encode(%ERQ{}) == []
    end
  end
end
