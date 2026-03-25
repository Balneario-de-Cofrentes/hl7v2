defmodule HL7v2.Segment.RF1Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.RF1

  describe "fields/0" do
    test "returns 11 field definitions" do
      assert length(RF1.fields()) == 11
    end
  end

  describe "segment_id/0" do
    test "returns RF1" do
      assert RF1.segment_id() == "RF1"
    end
  end

  describe "parse/1" do
    test "parses referral info" do
      raw = [
        ["A", "Accepted"],
        ["S", "Stat"],
        ["MED", "Medical"],
        "",
        ["LAB", "Laboratory"],
        ["REF001", "HOSP"]
      ]

      result = RF1.parse(raw)

      assert %RF1{} = result
      assert %HL7v2.Type.CE{identifier: "A"} = result.referral_status
      assert %HL7v2.Type.CE{identifier: "S"} = result.referral_priority
      assert %HL7v2.Type.CE{identifier: "MED"} = result.referral_type
      assert %HL7v2.Type.EI{entity_identifier: "REF001"} = result.originating_referral_identifier
    end

    test "parses empty list" do
      result = RF1.parse([])

      assert %RF1{} = result
      assert result.referral_status == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert RF1.encode(%RF1{}) == []
    end
  end
end
