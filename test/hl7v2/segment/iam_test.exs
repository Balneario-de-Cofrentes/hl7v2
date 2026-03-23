defmodule HL7v2.Segment.IAMTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.IAM

  describe "fields/0" do
    test "returns 20 field definitions" do
      assert length(IAM.fields()) == 20
    end
  end

  describe "segment_id/0" do
    test "returns IAM" do
      assert IAM.segment_id() == "IAM"
    end
  end

  describe "parse/1" do
    test "parses set_id and required fields" do
      raw = [
        "1",
        ["DA", "Drug allergy", "HL70127"],
        ["70618", "Penicillin", "RxNorm"],
        "",
        "",
        ["A", "Active", "HL70323"]
      ]

      result = IAM.parse(raw)

      assert %IAM{} = result
      assert result.set_id == 1

      assert %HL7v2.Type.CE{
               identifier: "DA",
               text: "Drug allergy",
               name_of_coding_system: "HL70127"
             } = result.allergen_type_code

      assert %HL7v2.Type.CE{
               identifier: "70618",
               text: "Penicillin",
               name_of_coding_system: "RxNorm"
             } = result.allergen_code_mnemonic_description

      assert %HL7v2.Type.CNE{
               identifier: "A",
               text: "Active",
               name_of_coding_system: "HL70323"
             } = result.allergy_action_code
    end

    test "parses allergy_severity_code as CE" do
      raw = [
        "1",
        ["DA"],
        ["70618"],
        ["SV", "Severe", "HL70128"]
      ]

      result = IAM.parse(raw)

      assert %HL7v2.Type.CE{identifier: "SV", text: "Severe"} = result.allergy_severity_code
    end

    test "parses repeating allergy_reaction_code" do
      raw = [
        "1",
        ["DA"],
        ["70618"],
        "",
        ["Hives", "Anaphylaxis", "Rash"]
      ]

      result = IAM.parse(raw)

      assert result.allergy_reaction_code == ["Hives", "Anaphylaxis", "Rash"]
    end

    test "parses single allergy_reaction_code as list" do
      raw = ["1", ["DA"], ["70618"], "", "Rash"]

      result = IAM.parse(raw)

      assert result.allergy_reaction_code == ["Rash"]
    end

    test "parses allergy_unique_identifier as EI" do
      raw =
        Enum.concat(["1", ["DA"], ["70618"], "", "", ["A"]], [
          ["ALLERGY123", "NS", "2.16.840", "ISO"]
        ])

      result = IAM.parse(raw)

      assert %HL7v2.Type.EI{
               entity_identifier: "ALLERGY123",
               namespace_id: "NS"
             } = result.allergy_unique_identifier
    end

    test "parses action_reason" do
      raw = Enum.concat(["1", ["DA"], ["70618"], "", "", ["A"], ["ID1"]], ["Patient reported"])

      result = IAM.parse(raw)

      assert result.action_reason == "Patient reported"
    end

    test "parses sensitivity_to_causative_agent_code as CE" do
      raw = Enum.concat(List.duplicate("", 8), [["AD", "Adverse", "HL70436"]])

      result = IAM.parse(raw)

      assert %HL7v2.Type.CE{identifier: "AD", text: "Adverse"} =
               result.sensitivity_to_causative_agent_code
    end

    test "parses allergen_group_code_mnemonic_description as CE" do
      raw = Enum.concat(List.duplicate("", 9), [["ANTIBIOTIC", "Antibiotics", "L"]])

      result = IAM.parse(raw)

      assert %HL7v2.Type.CE{identifier: "ANTIBIOTIC"} =
               result.allergen_group_code_mnemonic_description
    end

    test "parses onset_date as DT" do
      raw = Enum.concat(List.duplicate("", 10), ["20250115"])

      result = IAM.parse(raw)

      assert result.onset_date == ~D[2025-01-15]
    end

    test "parses onset_date_text" do
      raw = Enum.concat(List.duplicate("", 11), ["Childhood"])

      result = IAM.parse(raw)

      assert result.onset_date_text == "Childhood"
    end

    test "parses reported_date_time as TS" do
      raw = Enum.concat(List.duplicate("", 12), [["20260322120000"]])

      result = IAM.parse(raw)

      assert %HL7v2.Type.TS{
               time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22, hour: 12}
             } = result.reported_date_time
    end

    test "parses reported_by as XPN" do
      raw = Enum.concat(List.duplicate("", 13), [["Smith", "Jane"]])

      result = IAM.parse(raw)

      assert %HL7v2.Type.XPN{
               family_name: %HL7v2.Type.FN{surname: "Smith"},
               given_name: "Jane"
             } = result.reported_by
    end

    test "parses relationship_to_patient_code as CE" do
      raw = Enum.concat(List.duplicate("", 14), [["SEL", "Self", "HL70063"]])

      result = IAM.parse(raw)

      assert %HL7v2.Type.CE{identifier: "SEL", text: "Self"} =
               result.relationship_to_patient_code
    end

    test "parses alert_device_code as CE" do
      raw = Enum.concat(List.duplicate("", 15), [["B", "Bracelet", "HL70437"]])

      result = IAM.parse(raw)

      assert %HL7v2.Type.CE{identifier: "B"} = result.alert_device_code
    end

    test "parses allergy_clinical_status_code as CE" do
      raw = Enum.concat(List.duplicate("", 16), [["A", "Active", "HL70438"]])

      result = IAM.parse(raw)

      assert %HL7v2.Type.CE{identifier: "A", text: "Active"} =
               result.allergy_clinical_status_code
    end

    test "parses statused_by_person as XCN" do
      raw = Enum.concat(List.duplicate("", 17), [["DOC1", "Brown"]])

      result = IAM.parse(raw)

      assert %HL7v2.Type.XCN{id_number: "DOC1"} = result.statused_by_person
    end

    test "parses statused_by_organization as XON" do
      raw = Enum.concat(List.duplicate("", 18), [["City Hospital"]])

      result = IAM.parse(raw)

      assert %HL7v2.Type.XON{organization_name: "City Hospital"} =
               result.statused_by_organization
    end

    test "parses statused_at_date_time as TS" do
      raw = Enum.concat(List.duplicate("", 19), [["20260322140000"]])

      result = IAM.parse(raw)

      assert %HL7v2.Type.TS{
               time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22, hour: 14}
             } = result.statused_at_date_time
    end

    test "parses empty list -- all fields nil" do
      result = IAM.parse([])

      assert %IAM{} = result
      assert result.set_id == nil
      assert result.allergen_type_code == nil
      assert result.allergen_code_mnemonic_description == nil
      assert result.allergy_severity_code == nil
      assert result.allergy_reaction_code == nil
      assert result.allergy_action_code == nil
      assert result.onset_date == nil
      assert result.reported_by == nil
      assert result.statused_by_person == nil
      assert result.statused_at_date_time == nil
    end
  end

  describe "encode/1" do
    test "round-trip with allergen info" do
      raw = [
        "1",
        ["DA", "Drug allergy", "HL70127"],
        ["70618", "Penicillin", "RxNorm"],
        "",
        "",
        ["A", "Active", "HL70323"]
      ]

      encoded = raw |> IAM.parse() |> IAM.encode()

      assert Enum.at(encoded, 0) == "1"
      assert Enum.at(encoded, 1) == ["DA", "Drug allergy", "HL70127"]
      assert Enum.at(encoded, 2) == ["70618", "Penicillin", "RxNorm"]
      assert Enum.at(encoded, 5) == ["A", "Active", "HL70323"]
    end

    test "round-trip with repeating allergy_reaction_code" do
      raw = [
        "1",
        ["DA"],
        ["70618"],
        "",
        ["Hives", "Anaphylaxis"]
      ]

      encoded = raw |> IAM.parse() |> IAM.encode()

      # Multiple repetitions of ST produce wrapped values
      assert Enum.at(encoded, 4) == [["Hives"], ["Anaphylaxis"]]
    end

    test "round-trip with reported_by XPN" do
      raw = Enum.concat(List.duplicate("", 13), [["Smith", "Jane"]])

      encoded = raw |> IAM.parse() |> IAM.encode()

      assert List.last(encoded) == ["Smith", "Jane"]
    end

    test "trailing nil fields trimmed" do
      iam = %IAM{
        set_id: 1,
        allergen_code_mnemonic_description: %HL7v2.Type.CE{identifier: "70618"}
      }

      encoded = IAM.encode(iam)

      assert length(encoded) == 3
      assert Enum.at(encoded, 0) == "1"
    end

    test "encodes all-nil struct to empty list" do
      assert IAM.encode(%IAM{}) == []
    end
  end

  describe "typed parsing integration" do
    test "message with IAM segment parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.5.1\r" <>
          "EVN|A01|20260322\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|I\r" <>
          "IAM|1|DA^Drug allergy^HL70127|70618^Penicillin^RxNorm|||A^Active^HL70323\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      iam = Enum.find(msg.segments, &is_struct(&1, IAM))
      assert %IAM{} = iam
      assert iam.set_id == 1
      assert %HL7v2.Type.CE{identifier: "70618"} = iam.allergen_code_mnemonic_description
    end
  end
end
