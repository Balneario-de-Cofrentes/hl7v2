defmodule HL7v2.Segment.QPDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.QPD

  describe "fields/0" do
    test "returns 3 field definitions" do
      assert length(QPD.fields()) == 3
    end
  end

  describe "segment_id/0" do
    test "returns QPD" do
      assert QPD.segment_id() == "QPD"
    end
  end

  describe "parse/1" do
    test "parses query name and tag" do
      raw = [["IHE_PDQ", "Patient Demographics Query"], "TAG001"]

      result = QPD.parse(raw)

      assert %QPD{} = result
      assert %HL7v2.Type.CE{identifier: "IHE_PDQ"} = result.message_query_name
      assert result.query_tag == "TAG001"
    end

    test "parses empty list" do
      result = QPD.parse([])

      assert %QPD{} = result
      assert result.message_query_name == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert QPD.encode(%QPD{}) == []
    end
  end
end
