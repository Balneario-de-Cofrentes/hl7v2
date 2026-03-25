defmodule HL7v2.Segment.QAKTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.QAK

  describe "fields/0" do
    test "returns 6 field definitions" do
      assert length(QAK.fields()) == 6
    end
  end

  describe "segment_id/0" do
    test "returns QAK" do
      assert QAK.segment_id() == "QAK"
    end
  end

  describe "parse/1" do
    test "parses query_tag and status" do
      raw = ["TAG001", "OK"]

      result = QAK.parse(raw)

      assert %QAK{} = result
      assert result.query_tag == "TAG001"
      assert result.query_response_status == "OK"
    end

    test "parses hit counts" do
      raw = ["TAG001", "OK", "", "100", "25", "75"]

      result = QAK.parse(raw)

      assert %HL7v2.Type.NM{value: "100"} = result.hit_count_total
      assert %HL7v2.Type.NM{value: "25"} = result.this_payload
      assert %HL7v2.Type.NM{value: "75"} = result.hits_remaining
    end

    test "parses empty list" do
      result = QAK.parse([])

      assert %QAK{} = result
      assert result.query_tag == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert QAK.encode(%QAK{}) == []
    end

    test "round-trip preserves data" do
      raw = ["TAG001", "OK"]

      encoded = raw |> QAK.parse() |> QAK.encode()

      assert Enum.at(encoded, 0) == "TAG001"
      assert Enum.at(encoded, 1) == "OK"
    end
  end
end
