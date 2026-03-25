defmodule HL7v2.Segment.ORGTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.ORG

  describe "fields/0" do
    test "returns 12 field definitions" do
      assert length(ORG.fields()) == 12
    end
  end

  describe "segment_id/0" do
    test "returns ORG" do
      assert ORG.segment_id() == "ORG"
    end
  end

  describe "parse/1" do
    test "parses set_id and organization unit" do
      raw = ["1", ["CARD", "Cardiology"]]

      result = ORG.parse(raw)

      assert result.set_id == 1
      assert %HL7v2.Type.CE{identifier: "CARD"} = result.organization_unit_code
    end

    test "parses primary_org_unit_indicator" do
      raw = ["1", "", "", "Y"]

      result = ORG.parse(raw)

      assert result.primary_org_unit_indicator == "Y"
    end

    test "parses empty list" do
      result = ORG.parse([])

      assert %ORG{} = result
      assert result.set_id == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert ORG.encode(%ORG{}) == []
    end
  end
end
