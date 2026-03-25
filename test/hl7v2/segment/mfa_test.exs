defmodule HL7v2.Segment.MFATest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.MFA

  describe "fields/0" do
    test "returns 6 field definitions" do
      assert length(MFA.fields()) == 6
    end
  end

  describe "segment_id/0" do
    test "returns MFA" do
      assert MFA.segment_id() == "MFA"
    end
  end

  describe "parse/1" do
    test "parses record_level_event_code" do
      raw = ["MAD", "CTL001"]

      result = MFA.parse(raw)

      assert %MFA{} = result
      assert result.record_level_event_code == "MAD"
      assert result.mfn_control_id == "CTL001"
    end

    test "parses empty list" do
      result = MFA.parse([])

      assert %MFA{} = result
      assert result.record_level_event_code == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert MFA.encode(%MFA{}) == []
    end
  end
end
