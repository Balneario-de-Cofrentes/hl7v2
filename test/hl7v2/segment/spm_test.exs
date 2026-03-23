defmodule HL7v2.Segment.SPMTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.SPM

  describe "fields/0" do
    test "returns 30 field definitions" do
      assert length(SPM.fields()) == 30
    end
  end

  describe "segment_id/0" do
    test "returns SPM" do
      assert SPM.segment_id() == "SPM"
    end
  end

  describe "parse/1" do
    test "parses set_id and specimen_type" do
      raw = ["1", "", "", ["BLD", "Blood", "HL70487"]]

      result = SPM.parse(raw)

      assert %SPM{} = result
      assert result.set_id == 1
      assert %HL7v2.Type.CWE{identifier: "BLD", text: "Blood"} = result.specimen_type
    end

    test "parses specimen_id as EIP" do
      raw = [
        "1",
        [["SP001", "", "", ""], ["SP001-F", "", "", ""]],
        "",
        ["BLD", "Blood"]
      ]

      result = SPM.parse(raw)

      assert %HL7v2.Type.EIP{} = result.specimen_id
    end

    test "parses specimen_type_modifier as repeating CWE" do
      raw = [
        "1",
        "",
        "",
        ["BLD", "Blood"],
        [["VENOUS", "Venous"], ["FRESH", "Fresh"]]
      ]

      result = SPM.parse(raw)

      assert [
               %HL7v2.Type.CWE{identifier: "VENOUS"},
               %HL7v2.Type.CWE{identifier: "FRESH"}
             ] = result.specimen_type_modifier
    end

    test "parses specimen_collection_method" do
      raw = List.duplicate("", 6) ++ [["VEN", "Venipuncture"]]

      result = SPM.parse(raw)

      assert %HL7v2.Type.CWE{identifier: "VEN"} = result.specimen_collection_method
    end

    test "parses specimen_source_site and modifier" do
      raw =
        List.duplicate("", 7) ++
          [
            ["LA", "Left Arm"],
            [["ANT", "Anterior"]]
          ]

      result = SPM.parse(raw)

      assert %HL7v2.Type.CWE{identifier: "LA"} = result.specimen_source_site
      assert [%HL7v2.Type.CWE{identifier: "ANT"}] = result.specimen_source_site_modifier
    end

    test "parses specimen_collection_amount as CQ" do
      raw = List.duplicate("", 11) ++ [["10", ["mL", "milliliter"]]]

      result = SPM.parse(raw)

      assert %HL7v2.Type.CQ{quantity: "10"} = result.specimen_collection_amount
    end

    test "parses grouped_specimen_count" do
      raw = List.duplicate("", 12) ++ ["3"]

      result = SPM.parse(raw)

      assert %HL7v2.Type.NM{value: "3"} = result.grouped_specimen_count
    end

    test "parses specimen_received_date_time" do
      raw = List.duplicate("", 17) ++ [["20260322143000"]]

      result = SPM.parse(raw)

      assert %HL7v2.Type.TS{
               time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22, hour: 14}
             } = result.specimen_received_date_time
    end

    test "parses empty list — all fields nil" do
      result = SPM.parse([])

      assert %SPM{} = result
      assert result.set_id == nil
      assert result.specimen_type == nil
      assert result.specimen_collection_amount == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["1", "", "", ["BLD", "Blood", "HL70487"]]

      encoded = raw |> SPM.parse() |> SPM.encode()
      reparsed = SPM.parse(encoded)

      assert reparsed.set_id == 1
      assert reparsed.specimen_type.identifier == "BLD"
    end

    test "trailing nil fields trimmed" do
      spm = %SPM{
        set_id: 1,
        specimen_type: %HL7v2.Type.CWE{identifier: "BLD", text: "Blood"}
      }

      encoded = SPM.encode(spm)

      assert length(encoded) == 4
    end

    test "encodes all-nil struct to empty list" do
      assert SPM.encode(%SPM{}) == []
    end
  end

  describe "typed parsing integration" do
    test "OUL^R22 with SPM parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||OUL^R22|1|P|2.5.1\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "SPM|1|||BLD^Blood^HL70487\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      spm = Enum.find(msg.segments, &is_struct(&1, SPM))
      assert %SPM{set_id: 1} = spm
      assert spm.specimen_type.identifier == "BLD"
    end
  end
end
