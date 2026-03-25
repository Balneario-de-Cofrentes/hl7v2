defmodule HL7v2.Segment.VTQTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.VTQ

  describe "fields/0" do
    test "returns 5 field definitions" do
      assert length(VTQ.fields()) == 5
    end
  end

  describe "segment_id/0" do
    test "returns VTQ" do
      assert VTQ.segment_id() == "VTQ"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = VTQ.parse([])
      assert %VTQ{} = result
      assert result.query_tag == nil
    end

    test "parses query tag and virtual table name" do
      raw = ["TAG1", "R", ["Q001", "VTQuery"], ["PATIENT", "Patient Table"]]
      result = VTQ.parse(raw)

      assert result.query_tag == "TAG1"
      assert result.query_response_format_code == "R"
      assert %HL7v2.Type.CE{identifier: "Q001"} = result.vtq_query_name
      assert %HL7v2.Type.CE{identifier: "PATIENT"} = result.virtual_table_name
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["TAG1", "R", ["Q001", "VTQuery"], ["PATIENT", "Patient Table"]]
      encoded = raw |> VTQ.parse() |> VTQ.encode()
      reparsed = VTQ.parse(encoded)
      assert reparsed.query_tag == "TAG1"
      assert reparsed.virtual_table_name.identifier == "PATIENT"
    end

    test "encodes all-nil struct to empty list" do
      assert VTQ.encode(%VTQ{}) == []
    end
  end
end
