defmodule HL7v2.Segment.BTSTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.BTS

  describe "fields/0" do
    test "returns 3 field definitions" do
      assert length(BTS.fields()) == 3
    end
  end

  describe "segment_id/0" do
    test "returns BTS" do
      assert BTS.segment_id() == "BTS"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = BTS.parse([])
      assert %BTS{} = result
      assert result.batch_message_count == nil
      assert result.batch_comment == nil
      assert result.batch_totals == nil
    end

    test "parses batch trailer fields" do
      result = BTS.parse(["10", "End of batch", "12345.67"])
      assert result.batch_message_count == "10"
      assert result.batch_comment == "End of batch"
      assert [%HL7v2.Type.NM{value: "12345.67"}] = result.batch_totals
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["5", "Batch done"]
      encoded = raw |> BTS.parse() |> BTS.encode()
      reparsed = BTS.parse(encoded)
      assert reparsed.batch_message_count == "5"
      assert reparsed.batch_comment == "Batch done"
    end

    test "encodes all-nil struct to empty list" do
      assert BTS.encode(%BTS{}) == []
    end
  end
end
