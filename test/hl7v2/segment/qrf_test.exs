defmodule HL7v2.Segment.QRFTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.QRF

  describe "fields/0" do
    test "returns 10 field definitions" do
      assert length(QRF.fields()) == 10
    end
  end

  describe "segment_id/0" do
    test "returns QRF" do
      assert QRF.segment_id() == "QRF"
    end
  end

  describe "parse/1" do
    test "parses where_subject_filter" do
      raw = [["OBR"]]

      result = QRF.parse(raw)

      assert %QRF{} = result
      assert ["OBR"] = result.where_subject_filter
    end

    test "parses search_confidence_threshold" do
      raw = List.duplicate("", 9) ++ ["90"]

      result = QRF.parse(raw)

      assert %HL7v2.Type.NM{value: "90"} = result.search_confidence_threshold
    end

    test "parses empty list" do
      result = QRF.parse([])

      assert %QRF{} = result
      assert result.where_subject_filter == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert QRF.encode(%QRF{}) == []
    end
  end
end
