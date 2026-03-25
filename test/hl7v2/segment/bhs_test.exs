defmodule HL7v2.Segment.BHSTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.BHS

  describe "fields/0" do
    test "returns 12 field definitions" do
      assert length(BHS.fields()) == 12
    end
  end

  describe "segment_id/0" do
    test "returns BHS" do
      assert BHS.segment_id() == "BHS"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = BHS.parse([])
      assert %BHS{} = result
      assert result.batch_field_separator == nil
    end

    test "parses batch header fields" do
      raw = ["|", "^~\\&", ["BatchSendApp"], ["BatchSendFac"]]
      result = BHS.parse(raw)
      assert result.batch_field_separator == "|"
      assert result.batch_encoding_characters == "^~\\&"
      assert %HL7v2.Type.HD{namespace_id: "BatchSendApp"} = result.batch_sending_application
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["|", "^~\\&", ["SendApp"], nil, nil, nil, nil, "SEC", "BATCH1"]
      encoded = raw |> BHS.parse() |> BHS.encode()
      reparsed = BHS.parse(encoded)
      assert reparsed.batch_field_separator == "|"
      assert reparsed.batch_security == "SEC"
      assert reparsed.batch_name_type_id == "BATCH1"
    end

    test "encodes all-nil struct to empty list" do
      assert BHS.encode(%BHS{}) == []
    end
  end
end
