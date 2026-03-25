defmodule HL7v2.Segment.EDUTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.EDU

  describe "fields/0" do
    test "returns 9 field definitions" do
      assert length(EDU.fields()) == 9
    end
  end

  describe "segment_id/0" do
    test "returns EDU" do
      assert EDU.segment_id() == "EDU"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = EDU.parse([])
      assert %EDU{} = result
      assert result.set_id == nil
    end

    test "parses educational detail" do
      raw = [
        "1",
        "MD",
        nil,
        nil,
        "20100601"
      ]

      result = EDU.parse(raw)
      assert result.set_id == 1
      assert result.academic_degree == "MD"
      assert result.academic_degree_granted_date == ~D[2010-06-01]
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["1", "PhD", nil, nil, "20150901"]
      encoded = raw |> EDU.parse() |> EDU.encode()
      reparsed = EDU.parse(encoded)
      assert reparsed.set_id == 1
      assert reparsed.academic_degree == "PhD"
      assert reparsed.academic_degree_granted_date == ~D[2015-09-01]
    end

    test "encodes all-nil struct to empty list" do
      assert EDU.encode(%EDU{}) == []
    end
  end
end
