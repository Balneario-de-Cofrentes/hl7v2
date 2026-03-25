defmodule HL7v2.Segment.ADDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.ADD

  describe "fields/0" do
    test "returns 1 field definition" do
      assert length(ADD.fields()) == 1
    end
  end

  describe "segment_id/0" do
    test "returns ADD" do
      assert ADD.segment_id() == "ADD"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = ADD.parse([])
      assert %ADD{} = result
      assert result.addendum_continuation_pointer == nil
    end

    test "parses addendum continuation pointer" do
      result = ADD.parse(["Some continuation text"])
      assert result.addendum_continuation_pointer == "Some continuation text"
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["Addendum text here"]
      encoded = raw |> ADD.parse() |> ADD.encode()
      reparsed = ADD.parse(encoded)
      assert reparsed.addendum_continuation_pointer == "Addendum text here"
    end

    test "encodes all-nil struct to empty list" do
      assert ADD.encode(%ADD{}) == []
    end
  end
end
