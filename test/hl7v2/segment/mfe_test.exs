defmodule HL7v2.Segment.MFETest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.MFE

  describe "fields/0" do
    test "returns 5 field definitions" do
      assert length(MFE.fields()) == 5
    end
  end

  describe "segment_id/0" do
    test "returns MFE" do
      assert MFE.segment_id() == "MFE"
    end
  end

  describe "parse/1" do
    test "parses event code and control id" do
      raw = ["MAD", "CTL001"]

      result = MFE.parse(raw)

      assert %MFE{} = result
      assert result.record_level_event_code == "MAD"
      assert result.mfn_control_id == "CTL001"
    end

    test "parses empty list" do
      result = MFE.parse([])

      assert %MFE{} = result
      assert result.record_level_event_code == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert MFE.encode(%MFE{}) == []
    end
  end
end
