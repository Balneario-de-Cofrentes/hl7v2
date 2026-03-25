defmodule HL7v2.Segment.CDMTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.CDM

  describe "fields/0" do
    test "returns 13 field definitions" do
      assert length(CDM.fields()) == 13
    end
  end

  describe "segment_id/0" do
    test "returns CDM" do
      assert CDM.segment_id() == "CDM"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = CDM.parse([])
      assert %CDM{} = result
      assert result.primary_key_value == nil
    end

    test "parses charge description master" do
      raw = [
        ["CHG001", "Lab Test", "LOCAL"],
        nil,
        "Blood Panel",
        "Complete Blood Count Panel",
        "Y"
      ]

      result = CDM.parse(raw)
      assert %HL7v2.Type.CE{identifier: "CHG001"} = result.primary_key_value
      assert result.charge_description_short == "Blood Panel"
      assert result.charge_description_long == "Complete Blood Count Panel"
      assert result.description_override_indicator == "Y"
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [["CHG001", "Lab Test"], nil, "Blood Panel"]
      encoded = raw |> CDM.parse() |> CDM.encode()
      reparsed = CDM.parse(encoded)
      assert reparsed.primary_key_value.identifier == "CHG001"
      assert reparsed.charge_description_short == "Blood Panel"
    end

    test "encodes all-nil struct to empty list" do
      assert CDM.encode(%CDM{}) == []
    end
  end
end
