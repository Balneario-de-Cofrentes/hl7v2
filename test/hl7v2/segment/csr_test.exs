defmodule HL7v2.Segment.CSRTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.CSR

  describe "fields/0" do
    test "returns 16 field definitions" do
      assert length(CSR.fields()) == 16
    end
  end

  describe "segment_id/0" do
    test "returns CSR" do
      assert CSR.segment_id() == "CSR"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = CSR.parse([])
      assert %CSR{} = result
      assert result.sponsor_study_id == nil
    end

    test "parses clinical study registration" do
      raw = [
        ["STUDY001", "SPONSOR"],
        nil,
        ["HOSP01", "City Hospital", "LOCAL"],
        ["PAT001", "", "", "", "SPONSOR"]
      ]

      result = CSR.parse(raw)
      assert %HL7v2.Type.EI{entity_identifier: "STUDY001"} = result.sponsor_study_id
      assert %HL7v2.Type.CE{identifier: "HOSP01"} = result.institution_registering_the_patient
      assert %HL7v2.Type.CX{id: "PAT001"} = result.sponsor_patient_id
    end

    test "parses typed trailing fields" do
      raw = List.duplicate(nil, 12) ++ [["STRATUM01", "High Risk", "STRATA"]]
      result = CSR.parse(raw)
      assert [%HL7v2.Type.CE{identifier: "STRATUM01"}] = result.stratum_for_study_randomization
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [["STUDY001", "SPONSOR"]]
      encoded = raw |> CSR.parse() |> CSR.encode()
      reparsed = CSR.parse(encoded)
      assert reparsed.sponsor_study_id.entity_identifier == "STUDY001"
    end

    test "encodes all-nil struct to empty list" do
      assert CSR.encode(%CSR{}) == []
    end
  end
end
