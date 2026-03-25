defmodule HL7v2.Segment.RDFTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.RDF

  describe "fields/0" do
    test "returns 2 field definitions" do
      assert length(RDF.fields()) == 2
    end
  end

  describe "segment_id/0" do
    test "returns RDF" do
      assert RDF.segment_id() == "RDF"
    end
  end

  describe "parse/1" do
    test "parses number_of_columns" do
      raw = ["3"]

      result = RDF.parse(raw)

      assert %RDF{} = result
      assert %HL7v2.Type.NM{value: "3"} = result.number_of_columns_per_row
    end

    test "parses empty list" do
      result = RDF.parse([])

      assert %RDF{} = result
      assert result.number_of_columns_per_row == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert RDF.encode(%RDF{}) == []
    end
  end
end
