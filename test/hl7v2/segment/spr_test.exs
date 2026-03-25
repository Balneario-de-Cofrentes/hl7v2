defmodule HL7v2.Segment.SPRTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.SPR

  describe "fields/0" do
    test "returns 4 field definitions" do
      assert length(SPR.fields()) == 4
    end
  end

  describe "segment_id/0" do
    test "returns SPR" do
      assert SPR.segment_id() == "SPR"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = SPR.parse([])
      assert %SPR{} = result
      assert result.query_tag == nil
    end

    test "parses query tag and stored procedure name" do
      raw = ["TAG1", "R", ["SP001", "PatientLookup"]]
      result = SPR.parse(raw)

      assert result.query_tag == "TAG1"
      assert result.query_response_format_code == "R"
      assert %HL7v2.Type.CE{identifier: "SP001"} = result.stored_procedure_name
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["TAG1", "R", ["SP001", "PatientLookup"]]
      encoded = raw |> SPR.parse() |> SPR.encode()
      reparsed = SPR.parse(encoded)
      assert reparsed.query_tag == "TAG1"
      assert reparsed.stored_procedure_name.identifier == "SP001"
    end

    test "encodes all-nil struct to empty list" do
      assert SPR.encode(%SPR{}) == []
    end
  end
end
