defmodule HL7v2.Segment.QRITest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.QRI

  describe "fields/0" do
    test "returns 3 field definitions" do
      assert length(QRI.fields()) == 3
    end
  end

  describe "segment_id/0" do
    test "returns QRI" do
      assert QRI.segment_id() == "QRI"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = QRI.parse([])
      assert %QRI{} = result
      assert result.candidate_confidence == nil
    end

    test "parses confidence and algorithm" do
      raw = ["95", "SS", ["ALGO1", "Phonetic Match"]]
      result = QRI.parse(raw)

      assert %HL7v2.Type.NM{value: "95"} = result.candidate_confidence
      assert ["SS"] = result.match_reason_code
      assert %HL7v2.Type.CE{identifier: "ALGO1"} = result.algorithm_descriptor
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["95", "SS", ["ALGO1", "Phonetic Match"]]
      encoded = raw |> QRI.parse() |> QRI.encode()
      reparsed = QRI.parse(encoded)
      assert reparsed.candidate_confidence.value == "95"
      assert reparsed.algorithm_descriptor.identifier == "ALGO1"
    end

    test "encodes all-nil struct to empty list" do
      assert QRI.encode(%QRI{}) == []
    end
  end
end
