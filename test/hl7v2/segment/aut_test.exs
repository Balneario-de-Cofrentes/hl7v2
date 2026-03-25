defmodule HL7v2.Segment.AUTTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.AUT

  describe "fields/0" do
    test "returns 10 field definitions" do
      assert length(AUT.fields()) == 10
    end
  end

  describe "segment_id/0" do
    test "returns AUT" do
      assert AUT.segment_id() == "AUT"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = AUT.parse([])
      assert %AUT{} = result
      assert result.authorizing_payor_plan_id == nil
      assert result.authorizing_payor_company_id == nil
    end

    test "parses authorization information" do
      raw = [
        ["PLAN001", "Blue Cross", "PLANS"],
        ["COMP001", "BC Company", "COMP"],
        "Blue Cross Blue Shield",
        ["20260101"],
        ["20261231"],
        ["AUTH123", "HOSP"]
      ]

      result = AUT.parse(raw)
      assert %HL7v2.Type.CE{identifier: "PLAN001"} = result.authorizing_payor_plan_id
      assert %HL7v2.Type.CE{identifier: "COMP001"} = result.authorizing_payor_company_id
      assert result.authorizing_payor_company_name == "Blue Cross Blue Shield"
      assert %HL7v2.Type.EI{entity_identifier: "AUTH123"} = result.authorization_identifier
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [
        ["PLAN001", "Blue Cross"],
        ["COMP001", "BC Company"],
        "Blue Cross Blue Shield"
      ]

      encoded = raw |> AUT.parse() |> AUT.encode()
      reparsed = AUT.parse(encoded)
      assert reparsed.authorizing_payor_plan_id.identifier == "PLAN001"
      assert reparsed.authorizing_payor_company_name == "Blue Cross Blue Shield"
    end

    test "encodes all-nil struct to empty list" do
      assert AUT.encode(%AUT{}) == []
    end
  end
end
