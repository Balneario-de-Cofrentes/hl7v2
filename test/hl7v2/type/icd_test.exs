defmodule HL7v2.Type.ICDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.{ICD, TS, DTM}

  doctest ICD

  describe "parse/1" do
    test "parses all components" do
      result = ICD.parse(["ER", "Y", "20260101"])
      assert result.certification_patient_type == "ER"
      assert result.certification_required == "Y"
      assert %TS{time: %DTM{year: 2026}} = result.date_time_certification_required
    end

    test "parses empty list" do
      result = ICD.parse([])
      assert result.certification_patient_type == nil
    end
  end

  describe "encode/1" do
    test "encodes partial ICD" do
      icd = %ICD{certification_patient_type: "ER", certification_required: "Y"}
      assert ICD.encode(icd) == ["ER", "Y"]
    end

    test "encodes nil" do
      assert ICD.encode(nil) == []
    end
  end
end
