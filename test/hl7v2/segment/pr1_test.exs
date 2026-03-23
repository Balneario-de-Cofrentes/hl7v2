defmodule HL7v2.Segment.PR1Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.PR1

  describe "fields/0" do
    test "returns 20 field definitions" do
      assert length(PR1.fields()) == 20
    end
  end

  describe "segment_id/0" do
    test "returns PR1" do
      assert PR1.segment_id() == "PR1"
    end
  end

  describe "parse/1" do
    test "parses set_id, procedure_code, and date_time" do
      raw = [
        "1",
        "",
        ["99213", "Office Visit", "CPT"],
        "",
        ["20260315140000"]
      ]

      result = PR1.parse(raw)

      assert %PR1{} = result
      assert result.set_id == 1

      assert %HL7v2.Type.CE{
               identifier: "99213",
               text: "Office Visit",
               name_of_coding_system: "CPT"
             } =
               result.procedure_code

      assert %HL7v2.Type.TS{
               time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 15, hour: 14}
             } = result.procedure_date_time
    end

    test "parses procedure_functional_type and minutes" do
      raw = ["1", "", ["99213", "Visit", "CPT"], "", ["20260315"], "A", "45"]

      result = PR1.parse(raw)

      assert result.procedure_functional_type == "A"
      assert %HL7v2.Type.NM{value: "45"} = result.procedure_minutes
    end

    test "parses anesthesia fields" do
      raw = ["1", "", ["99213", "Visit"], "", ["20260315"], "", "", "", "00100", "120"]

      result = PR1.parse(raw)

      assert result.anesthesia_code == "00100"
      assert %HL7v2.Type.NM{value: "120"} = result.anesthesia_minutes
    end

    test "parses consent_code and procedure_priority" do
      raw = List.duplicate("", 12) ++ [["CON1", "Informed Consent"], "2"]

      result = PR1.parse(raw)

      assert %HL7v2.Type.CE{identifier: "CON1"} = result.consent_code
      assert result.procedure_priority == "2"
    end

    test "parses procedure_code_modifier as repeating CE" do
      raw = List.duplicate("", 15) ++ [[["MOD1", "Modifier 1"], ["MOD2", "Modifier 2"]]]

      result = PR1.parse(raw)

      assert [%HL7v2.Type.CE{identifier: "MOD1"}, %HL7v2.Type.CE{identifier: "MOD2"}] =
               result.procedure_code_modifier
    end

    test "parses procedure_identifier as EI" do
      raw = List.duplicate("", 18) ++ [["PROC-001", "", "", ""]]

      result = PR1.parse(raw)

      assert %HL7v2.Type.EI{entity_identifier: "PROC-001"} = result.procedure_identifier
    end

    test "parses procedure_action_code" do
      raw = List.duplicate("", 19) ++ ["A"]

      result = PR1.parse(raw)

      assert result.procedure_action_code == "A"
    end

    test "parses empty list — all fields nil" do
      result = PR1.parse([])

      assert %PR1{} = result
      assert result.set_id == nil
      assert result.procedure_code == nil
      assert result.procedure_date_time == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [
        "1",
        "",
        ["99213", "Office Visit", "CPT"],
        "",
        ["20260315140000"]
      ]

      encoded = raw |> PR1.parse() |> PR1.encode()
      reparsed = PR1.parse(encoded)

      assert reparsed.set_id == 1
      assert reparsed.procedure_code.identifier == "99213"
    end

    test "trailing nil fields trimmed" do
      pr1 = %PR1{
        set_id: 1,
        procedure_code: %HL7v2.Type.CE{identifier: "99213"},
        procedure_date_time: %HL7v2.Type.TS{
          time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 15}
        }
      }

      encoded = PR1.encode(pr1)

      assert length(encoded) == 5
    end

    test "encodes all-nil struct to empty list" do
      assert PR1.encode(%PR1{}) == []
    end
  end
end
