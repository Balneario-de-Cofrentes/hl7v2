defmodule HL7v2.Segment.PD1Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.PD1

  describe "fields/0" do
    test "returns 21 field definitions" do
      assert length(PD1.fields()) == 21
    end
  end

  describe "segment_id/0" do
    test "returns PD1" do
      assert PD1.segment_id() == "PD1"
    end
  end

  describe "parse/1" do
    test "parses living dependency and arrangement" do
      raw = ["M", "S"]

      result = PD1.parse(raw)

      assert %PD1{} = result
      assert result.living_dependency == ["M"]
      assert result.living_arrangement == "S"
    end

    test "parses patient primary facility as repeating XON" do
      raw = ["", "", [["Hospital A"], ["Hospital B"]]]

      result = PD1.parse(raw)

      assert [%HL7v2.Type.XON{organization_name: "Hospital A"}, %HL7v2.Type.XON{organization_name: "Hospital B"}] =
               result.patient_primary_facility
    end

    test "parses student indicator" do
      raw = ["", "", "", "", "F"]

      result = PD1.parse(raw)

      assert result.student_indicator == "F"
    end

    test "parses living will and organ donor codes" do
      raw = ["", "", "", "", "", "", "Y", "N"]

      result = PD1.parse(raw)

      assert result.living_will_code == "Y"
      assert result.organ_donor_code == "N"
    end

    test "parses protection indicator and effective date" do
      raw = ["", "", "", "", "", "", "", "", "", "", "", "Y", "20260101"]

      result = PD1.parse(raw)

      assert result.protection_indicator == "Y"
      assert result.protection_indicator_effective_date == ~D[2026-01-01]
    end

    test "parses immunization registry status" do
      raw = List.duplicate("", 15) ++ ["A", "20260101"]

      result = PD1.parse(raw)

      assert result.immunization_registry_status == "A"
      assert result.immunization_registry_status_effective_date == ~D[2026-01-01]
    end

    test "parses military fields" do
      raw = List.duplicate("", 18) ++ ["USN", "E5", "ACT"]

      result = PD1.parse(raw)

      assert result.military_branch == "USN"
      assert result.military_rank_grade == "E5"
      assert result.military_status == "ACT"
    end

    test "parses empty list — all fields nil" do
      result = PD1.parse([])

      assert %PD1{} = result
      assert result.living_dependency == nil
      assert result.living_arrangement == nil
      assert result.patient_primary_facility == nil
      assert result.student_indicator == nil
      assert result.military_status == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["M", "S", ["Hospital A"]]

      encoded = raw |> PD1.parse() |> PD1.encode()
      reparsed = PD1.parse(encoded)

      assert reparsed.living_dependency == ["M"]
      assert reparsed.living_arrangement == "S"
    end

    test "trailing nil fields trimmed" do
      pd1 = %PD1{living_arrangement: "S"}

      encoded = PD1.encode(pd1)

      assert length(encoded) == 2
    end

    test "encodes all-nil struct to empty list" do
      assert PD1.encode(%PD1{}) == []
    end
  end

  describe "typed parsing integration" do
    test "ADT^A01 with PD1 parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.5.1\r" <>
          "EVN|A01|20260322\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PD1||S\r" <>
          "PV1|1|I\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      pd1 = Enum.find(msg.segments, &is_struct(&1, PD1))
      assert %PD1{living_arrangement: "S"} = pd1
    end
  end
end
