defmodule HL7v2.Segment.MRGTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.MRG
  alias HL7v2.Type.{CX, XPN, FN}

  describe "parse/1" do
    test "parses MRG with prior patient identifiers" do
      raw = [
        [["12345", "", "", "MRN", "MR"]],
        nil,
        nil,
        nil,
        nil,
        nil,
        [["Smith", "John"]]
      ]

      mrg = MRG.parse(raw)
      assert %MRG{} = mrg
      assert [%CX{id: "12345", identifier_type_code: "MR"}] = mrg.prior_patient_identifier_list
      assert [%XPN{given_name: "John"}] = mrg.prior_patient_name
    end

    test "parses minimal MRG" do
      raw = ["12345"]
      mrg = MRG.parse(raw)
      assert %MRG{} = mrg
      assert [%CX{id: "12345"}] = mrg.prior_patient_identifier_list
    end

    test "parses MRG with multiple prior identifiers" do
      raw = [
        [["12345", "", "", "MRN", "MR"], ["67890", "", "", "SSN", "SS"]]
      ]

      mrg = MRG.parse(raw)
      assert length(mrg.prior_patient_identifier_list) == 2
      assert Enum.map(mrg.prior_patient_identifier_list, & &1.id) == ["12345", "67890"]
    end
  end

  describe "encode/1" do
    test "encodes MRG struct" do
      mrg = %MRG{
        prior_patient_identifier_list: [%CX{id: "12345", identifier_type_code: "MR"}],
        prior_patient_name: [
          %XPN{family_name: %FN{surname: "Smith"}, given_name: "John"}
        ]
      }

      encoded = MRG.encode(mrg)
      assert is_list(encoded)
      assert length(encoded) > 0
    end

    test "round-trip preserves data" do
      raw = [
        [["12345", "", "", "MRN", "MR"]],
        nil,
        nil,
        nil,
        nil,
        nil,
        [["Smith", "John"]]
      ]

      mrg = MRG.parse(raw)
      encoded = MRG.encode(mrg)
      reparsed = MRG.parse(encoded)

      assert reparsed.prior_patient_identifier_list == mrg.prior_patient_identifier_list
      assert reparsed.prior_patient_name == mrg.prior_patient_name
    end
  end

  describe "segment metadata" do
    test "segment_id is MRG" do
      assert MRG.segment_id() == "MRG"
    end

    test "has 7 fields" do
      assert length(MRG.fields()) == 7
    end
  end
end
