defmodule HL7v2.Segment.QRDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.QRD

  describe "fields/0" do
    test "returns 12 field definitions" do
      assert length(QRD.fields()) == 12
    end
  end

  describe "segment_id/0" do
    test "returns QRD" do
      assert QRD.segment_id() == "QRD"
    end
  end

  describe "parse/1" do
    test "parses query info" do
      raw = [["20260301"], "R", "I", "QRY001"]

      result = QRD.parse(raw)

      assert %QRD{} = result
      assert %HL7v2.Type.TS{} = result.query_date_time
      assert result.query_format_code == "R"
      assert result.query_priority == "I"
      assert result.query_id == "QRY001"
    end

    test "parses empty list" do
      result = QRD.parse([])

      assert %QRD{} = result
      assert result.query_date_time == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert QRD.encode(%QRD{}) == []
    end
  end
end
