defmodule HL7v2.Segment.OVRTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.OVR

  describe "fields/0" do
    test "returns 5 field definitions" do
      assert length(OVR.fields()) == 5
    end
  end

  describe "segment_id/0" do
    test "returns OVR" do
      assert OVR.segment_id() == "OVR"
    end
  end

  describe "parse/1" do
    test "parses override type and code" do
      raw = [["DUPORD", "Duplicate Order"], ["OVERRIDE", "Override"]]

      result = OVR.parse(raw)

      assert %OVR{} = result
      assert %HL7v2.Type.CWE{identifier: "DUPORD"} = result.business_rule_override_type
      assert %HL7v2.Type.CWE{identifier: "OVERRIDE"} = result.business_rule_override_code
    end

    test "parses override_comments" do
      raw = ["", "", "Patient consented"]

      result = OVR.parse(raw)

      assert result.override_comments == "Patient consented"
    end

    test "parses empty list" do
      result = OVR.parse([])

      assert %OVR{} = result
      assert result.business_rule_override_type == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert OVR.encode(%OVR{}) == []
    end
  end
end
