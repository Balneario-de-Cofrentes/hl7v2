defmodule HL7v2.Segment.PESTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.PES

  describe "fields/0" do
    test "returns 13 field definitions" do
      assert length(PES.fields()) == 13
    end
  end

  describe "segment_id/0" do
    test "returns PES" do
      assert PES.segment_id() == "PES"
    end
  end

  describe "parse/1" do
    test "parses sender_sequence_number" do
      raw = List.duplicate("", 5) ++ ["1"]

      result = PES.parse(raw)

      assert %PES{} = result
      assert %HL7v2.Type.NM{value: "1"} = result.sender_sequence_number
    end

    test "parses empty list" do
      result = PES.parse([])

      assert %PES{} = result
      assert result.sender_organization_name == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert PES.encode(%PES{}) == []
    end
  end
end
