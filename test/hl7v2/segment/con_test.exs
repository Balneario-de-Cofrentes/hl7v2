defmodule HL7v2.Segment.CONTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.CON

  describe "fields/0" do
    test "returns 25 field definitions" do
      assert length(CON.fields()) == 25
    end
  end

  describe "segment_id/0" do
    test "returns CON" do
      assert CON.segment_id() == "CON"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = CON.parse([])
      assert %CON{} = result
      assert result.set_id == nil
      assert result.consent_type == nil
    end

    test "parses consent segment typed fields" do
      raw = [
        "1",
        ["INFORMED", "Informed Consent", "CONSENT_TYPES"],
        "FORM-001",
        ["CON12345", "HOSP"]
      ]

      result = CON.parse(raw)
      assert result.set_id == 1
      assert %HL7v2.Type.CWE{identifier: "INFORMED"} = result.consent_type
      assert result.consent_form_id == "FORM-001"
      assert %HL7v2.Type.EI{entity_identifier: "CON12345"} = result.consent_form_number
    end

    test "parses typed trailing fields" do
      raw = List.duplicate(nil, 15) ++ ["Y"]
      result = CON.parse(raw)
      assert result.subject_competence_indicator == "Y"
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["1", ["INFORMED", "Informed Consent"], "FORM-001"]
      encoded = raw |> CON.parse() |> CON.encode()
      reparsed = CON.parse(encoded)
      assert reparsed.set_id == 1
      assert reparsed.consent_type.identifier == "INFORMED"
    end

    test "encodes all-nil struct to empty list" do
      assert CON.encode(%CON{}) == []
    end
  end
end
