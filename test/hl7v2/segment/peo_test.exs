defmodule HL7v2.Segment.PEOTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.PEO

  describe "fields/0" do
    test "returns 25 field definitions" do
      assert length(PEO.fields()) == 25
    end
  end

  describe "segment_id/0" do
    test "returns PEO" do
      assert PEO.segment_id() == "PEO"
    end
  end

  describe "parse/1" do
    test "parses event_onset_date_time" do
      raw = ["", "", ["20260301120000"]]

      result = PEO.parse(raw)

      assert %PEO{} = result
      assert %HL7v2.Type.TS{time: %HL7v2.Type.DTM{year: 2026}} = result.event_onset_date_time
    end

    test "parses empty list" do
      result = PEO.parse([])

      assert %PEO{} = result
      assert result.event_onset_date_time == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert PEO.encode(%PEO{}) == []
    end
  end
end
