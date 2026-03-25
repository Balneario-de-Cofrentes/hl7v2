defmodule HL7v2.Segment.AFFTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.AFF

  describe "fields/0" do
    test "returns 5 field definitions" do
      assert length(AFF.fields()) == 5
    end
  end

  describe "segment_id/0" do
    test "returns AFF" do
      assert AFF.segment_id() == "AFF"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = AFF.parse([])
      assert %AFF{} = result
      assert result.set_id == nil
      assert result.professional_organization == nil
    end

    test "parses set_id and professional_organization" do
      raw = [
        "1",
        ["AMA", "American Medical Association"]
      ]

      result = AFF.parse(raw)

      assert result.set_id == 1
      assert %HL7v2.Type.XON{organization_name: "AMA"} = result.professional_organization
    end

    test "parses additional information" do
      raw = ["1", ["AMA"], nil, nil, "Board certified"]
      result = AFF.parse(raw)
      assert result.professional_affiliation_additional_information == "Board certified"
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["1", ["AMA", "American Medical Association"]]
      encoded = raw |> AFF.parse() |> AFF.encode()
      reparsed = AFF.parse(encoded)
      assert reparsed.set_id == 1
      assert reparsed.professional_organization.organization_name == "AMA"
    end

    test "encodes all-nil struct to empty list" do
      assert AFF.encode(%AFF{}) == []
    end
  end
end
