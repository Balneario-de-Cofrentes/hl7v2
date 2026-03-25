defmodule HL7v2.Segment.QIDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.QID

  describe "fields/0" do
    test "returns 2 field definitions" do
      assert length(QID.fields()) == 2
    end
  end

  describe "segment_id/0" do
    test "returns QID" do
      assert QID.segment_id() == "QID"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = QID.parse([])
      assert %QID{} = result
      assert result.query_tag == nil
      assert result.message_query_name == nil
    end

    test "parses query identification" do
      raw = ["Q001", ["QBP^Z95", "Query by parameter", "HL70471"]]
      result = QID.parse(raw)
      assert result.query_tag == "Q001"
      assert %HL7v2.Type.CE{identifier: "QBP^Z95"} = result.message_query_name
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["Q001", ["QRY_A19", "Patient query", "HL7"]]
      encoded = raw |> QID.parse() |> QID.encode()
      reparsed = QID.parse(encoded)
      assert reparsed.query_tag == "Q001"
      assert reparsed.message_query_name.identifier == "QRY_A19"
    end

    test "encodes all-nil struct to empty list" do
      assert QID.encode(%QID{}) == []
    end
  end
end
