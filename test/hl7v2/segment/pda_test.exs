defmodule HL7v2.Segment.PDATest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.PDA

  describe "fields/0" do
    test "returns 9 field definitions" do
      assert length(PDA.fields()) == 9
    end
  end

  describe "segment_id/0" do
    test "returns PDA" do
      assert PDA.segment_id() == "PDA"
    end
  end

  describe "parse/1" do
    test "parses death_cause_code as repeating CE" do
      raw = [[["I25.1", "Atherosclerotic heart disease", "ICD10"]]]

      result = PDA.parse(raw)

      assert %PDA{} = result

      assert [%HL7v2.Type.CE{identifier: "I25.1", text: "Atherosclerotic heart disease"}] =
               result.death_cause_code
    end

    test "parses death_location as PL" do
      raw = [
        "",
        ["ICU", "Room 4", "Bed 2", ["HOSP", "General Hospital"]]
      ]

      result = PDA.parse(raw)

      assert %HL7v2.Type.PL{point_of_care: "ICU", room: "Room 4"} = result.death_location
    end

    test "parses death_certified_indicator and date" do
      raw = ["", "", "Y", ["20260315143000"]]

      result = PDA.parse(raw)

      assert result.death_certified_indicator == "Y"

      assert %HL7v2.Type.TS{
               time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 15, hour: 14}
             } = result.death_certificate_signed_date_time
    end

    test "parses death_certified_by as XCN" do
      raw = List.duplicate("", 4) ++ [["DR001", "Smith", "John"]]

      result = PDA.parse(raw)

      assert %HL7v2.Type.XCN{id_number: "DR001"} = result.death_certified_by
    end

    test "parses autopsy fields" do
      raw =
        List.duplicate("", 5) ++
          [
            "Y",
            ["20260316080000", "20260316120000"],
            ["PA001", "Jones", "Mary"]
          ]

      result = PDA.parse(raw)

      assert result.autopsy_indicator == "Y"
      assert %HL7v2.Type.DR{} = result.autopsy_start_and_end_date_time
      assert %HL7v2.Type.XCN{id_number: "PA001"} = result.autopsy_performed_by
    end

    test "parses coroner_indicator" do
      raw = List.duplicate("", 8) ++ ["Y"]

      result = PDA.parse(raw)

      assert result.coroner_indicator == "Y"
    end

    test "parses empty list — all fields nil" do
      result = PDA.parse([])

      assert %PDA{} = result
      assert result.death_cause_code == nil
      assert result.death_location == nil
      assert result.autopsy_indicator == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [
        [["I25.1", "Heart disease"]],
        "",
        "Y",
        ["20260315143000"]
      ]

      encoded = raw |> PDA.parse() |> PDA.encode()
      reparsed = PDA.parse(encoded)

      assert reparsed.death_certified_indicator == "Y"
      assert [%HL7v2.Type.CE{identifier: "I25.1"}] = reparsed.death_cause_code
    end

    test "trailing nil fields trimmed" do
      pda = %PDA{death_certified_indicator: "Y"}

      encoded = PDA.encode(pda)

      assert length(encoded) == 3
    end

    test "encodes all-nil struct to empty list" do
      assert PDA.encode(%PDA{}) == []
    end
  end

  describe "typed parsing integration" do
    test "ADT^A01 with PDA parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.5.1\r" <>
          "EVN|A01|20260322\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|I\r" <>
          "PDA||ICU^Room 4|Y|20260315143000\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      pda = Enum.find(msg.segments, &is_struct(&1, PDA))
      assert %PDA{death_certified_indicator: "Y"} = pda
    end
  end
end
