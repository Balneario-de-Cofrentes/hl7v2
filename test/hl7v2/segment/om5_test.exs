defmodule HL7v2.Segment.OM5Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.OM5

  describe "fields/0" do
    test "returns 3 field definitions" do
      assert length(OM5.fields()) == 3
    end
  end

  describe "segment_id/0" do
    test "returns OM5" do
      assert OM5.segment_id() == "OM5"
    end
  end

  describe "parse/1" do
    test "parses sequence and suffixes" do
      raw = ["1", "", "A"]

      result = OM5.parse(raw)

      assert %OM5{} = result
      assert result.observation_id_suffixes == "A"
    end

    test "parses empty list" do
      result = OM5.parse([])

      assert %OM5{} = result
      assert result.sequence_number == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert OM5.encode(%OM5{}) == []
    end
  end
end
