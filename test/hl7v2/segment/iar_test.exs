defmodule HL7v2.Segment.IARTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.IAR
  alias HL7v2.Validation.FieldRules

  describe "fields/0" do
    test "returns 5 field definitions" do
      assert length(IAR.fields()) == 5
    end
  end

  describe "segment_id/0" do
    test "returns IAR" do
      assert IAR.segment_id() == "IAR"
    end
  end

  describe "parse/1" do
    test "parses wire line IAR|R001^Hives^HL70472|SV^Severe^HL70128|||" do
      raw = [
        ["R001", "Hives", "HL70472"],
        ["SV", "Severe", "HL70128"],
        "",
        "",
        ""
      ]

      result = IAR.parse(raw)

      assert %IAR{} = result

      assert %HL7v2.Type.CWE{
               identifier: "R001",
               text: "Hives",
               name_of_coding_system: "HL70472"
             } = result.allergy_reaction_code

      assert %HL7v2.Type.CWE{
               identifier: "SV",
               text: "Severe",
               name_of_coding_system: "HL70128"
             } = result.allergy_severity_code

      assert result.sensitivity_to_causative_agent_code == nil
      assert result.management == nil
      assert result.allergy_reaction_duration == nil
    end

    test "parses all 5 fields including CQ allergy_reaction_duration" do
      raw = [
        ["R001", "Hives", "HL70472"],
        ["MO", "Moderate", "HL70128"],
        ["AD", "Adverse", "HL70436"],
        "Administered antihistamine",
        ["30", "min&minutes&UCUM"]
      ]

      result = IAR.parse(raw)

      assert %HL7v2.Type.CWE{identifier: "R001"} = result.allergy_reaction_code
      assert %HL7v2.Type.CWE{identifier: "MO"} = result.allergy_severity_code

      assert %HL7v2.Type.CWE{identifier: "AD", text: "Adverse"} =
               result.sensitivity_to_causative_agent_code

      assert result.management == "Administered antihistamine"

      assert %HL7v2.Type.CQ{
               quantity: "30",
               units: %HL7v2.Type.CE{identifier: "min", text: "minutes"}
             } = result.allergy_reaction_duration
    end

    test "parses empty list — all fields nil" do
      result = IAR.parse([])

      assert %IAR{} = result
      assert result.allergy_reaction_code == nil
      assert result.allergy_severity_code == nil
      assert result.sensitivity_to_causative_agent_code == nil
      assert result.management == nil
      assert result.allergy_reaction_duration == nil
    end
  end

  describe "encode/1 round-trip" do
    test "parse → encode → parse preserves all fields" do
      raw = [
        ["R001", "Hives", "HL70472"],
        ["SV", "Severe", "HL70128"],
        ["AD", "Adverse", "HL70436"],
        "Administered antihistamine",
        ["30", "min&minutes&UCUM"]
      ]

      encoded = raw |> IAR.parse() |> IAR.encode()
      reparsed = IAR.parse(encoded)

      assert reparsed.allergy_reaction_code.identifier == "R001"
      assert reparsed.allergy_reaction_code.text == "Hives"
      assert reparsed.allergy_reaction_code.name_of_coding_system == "HL70472"
      assert reparsed.allergy_severity_code.identifier == "SV"
      assert reparsed.sensitivity_to_causative_agent_code.identifier == "AD"
      assert reparsed.management == "Administered antihistamine"
      assert reparsed.allergy_reaction_duration.quantity == "30"
      assert reparsed.allergy_reaction_duration.units.identifier == "min"
    end

    test "encodes all-nil struct to empty list" do
      assert IAR.encode(%IAR{}) == []
    end
  end

  describe "validation" do
    test "missing required allergy_reaction_code fails validation" do
      segment = %IAR{
        allergy_reaction_code: nil,
        allergy_severity_code: %HL7v2.Type.CWE{
          identifier: "SV",
          text: "Severe",
          name_of_coding_system: "HL70128"
        }
      }

      errors = FieldRules.check(segment)

      assert Enum.any?(errors, fn err ->
               err.level == :error and
                 err.location == "IAR" and
                 err.field == :allergy_reaction_code and
                 err.message =~ "required field allergy_reaction_code is missing"
             end)
    end

    test "populated required allergy_reaction_code passes validation" do
      segment = %IAR{
        allergy_reaction_code: %HL7v2.Type.CWE{
          identifier: "R001",
          text: "Hives",
          name_of_coding_system: "HL70472"
        }
      }

      errors = FieldRules.check(segment)

      refute Enum.any?(errors, &(&1.level == :error and &1.field == :allergy_reaction_code))
    end
  end

  describe "typed parsing integration" do
    test "wire line IAR parses as typed struct via HL7v2.parse/2" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.7\r" <>
          "EVN|A01|20260322\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|I\r" <>
          "IAM|1|DA^Drug allergy^HL70127|70618^Penicillin^RxNorm|||A^Active^HL70323\r" <>
          "IAR|R001^Hives^HL70472|SV^Severe^HL70128|||\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      iar = Enum.find(msg.segments, &is_struct(&1, IAR))

      assert %IAR{} = iar
      assert iar.allergy_reaction_code.identifier == "R001"
      assert iar.allergy_reaction_code.text == "Hives"
      assert iar.allergy_severity_code.identifier == "SV"
      assert iar.allergy_severity_code.text == "Severe"
    end
  end
end
