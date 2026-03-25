defmodule HL7v2.Segment.FTSTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.FTS

  describe "fields/0" do
    test "returns 2 field definitions" do
      assert length(FTS.fields()) == 2
    end
  end

  describe "segment_id/0" do
    test "returns FTS" do
      assert FTS.segment_id() == "FTS"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = FTS.parse([])
      assert %FTS{} = result
      assert result.file_batch_count == nil
      assert result.file_trailer_comment == nil
    end

    test "parses batch count and comment" do
      result = FTS.parse(["5", "End of file"])
      assert %HL7v2.Type.NM{value: "5"} = result.file_batch_count
      assert result.file_trailer_comment == "End of file"
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["3", "Trailer comment"]
      encoded = raw |> FTS.parse() |> FTS.encode()
      reparsed = FTS.parse(encoded)
      assert %HL7v2.Type.NM{value: "3"} = reparsed.file_batch_count
      assert reparsed.file_trailer_comment == "Trailer comment"
    end

    test "encodes all-nil struct to empty list" do
      assert FTS.encode(%FTS{}) == []
    end
  end
end
