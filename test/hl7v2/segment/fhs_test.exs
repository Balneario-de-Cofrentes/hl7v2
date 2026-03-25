defmodule HL7v2.Segment.FHSTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.FHS

  describe "fields/0" do
    test "returns 12 field definitions" do
      assert length(FHS.fields()) == 12
    end
  end

  describe "segment_id/0" do
    test "returns FHS" do
      assert FHS.segment_id() == "FHS"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = FHS.parse([])
      assert %FHS{} = result
      assert result.file_field_separator == nil
    end

    test "parses file header fields" do
      raw = ["|", "^~\\&", ["SendApp"], ["SendFac"], ["RecvApp"], ["RecvFac"]]
      result = FHS.parse(raw)
      assert result.file_field_separator == "|"
      assert result.file_encoding_characters == "^~\\&"
      assert %HL7v2.Type.HD{namespace_id: "SendApp"} = result.file_sending_application
      assert %HL7v2.Type.HD{namespace_id: "SendFac"} = result.file_sending_facility
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["|", "^~\\&", ["SendApp"], ["SendFac"]]
      encoded = raw |> FHS.parse() |> FHS.encode()
      reparsed = FHS.parse(encoded)
      assert reparsed.file_field_separator == "|"
      assert reparsed.file_encoding_characters == "^~\\&"
      assert reparsed.file_sending_application.namespace_id == "SendApp"
    end

    test "encodes all-nil struct to empty list" do
      assert FHS.encode(%FHS{}) == []
    end
  end
end
