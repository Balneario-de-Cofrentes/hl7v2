defmodule HL7v2.Segment.EQLTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.EQL

  describe "fields/0" do
    test "returns 4 field definitions" do
      assert length(EQL.fields()) == 4
    end
  end

  describe "segment_id/0" do
    test "returns EQL" do
      assert EQL.segment_id() == "EQL"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = EQL.parse([])
      assert %EQL{} = result
      assert result.query_tag == nil
    end

    test "parses all fields" do
      raw = ["TAG1", "R", ["Q001", "Patient Query"], "SELECT * FROM PATIENT"]
      result = EQL.parse(raw)

      assert result.query_tag == "TAG1"
      assert result.query_response_format_code == "R"
      assert %HL7v2.Type.CE{identifier: "Q001"} = result.eql_query_name
      assert result.eql_query_statement == "SELECT * FROM PATIENT"
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["TAG1", "R", ["Q001", "Patient Query"], "SELECT * FROM PATIENT"]
      encoded = raw |> EQL.parse() |> EQL.encode()
      reparsed = EQL.parse(encoded)
      assert reparsed.query_tag == "TAG1"
      assert reparsed.eql_query_statement == "SELECT * FROM PATIENT"
    end

    test "encodes all-nil struct to empty list" do
      assert EQL.encode(%EQL{}) == []
    end
  end
end
