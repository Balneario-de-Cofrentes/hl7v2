defmodule HL7v2.Segment.DB1Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.DB1

  describe "fields/0" do
    test "returns 8 field definitions" do
      assert length(DB1.fields()) == 8
    end
  end

  describe "segment_id/0" do
    test "returns DB1" do
      assert DB1.segment_id() == "DB1"
    end
  end

  describe "parse/1" do
    test "parses set_id and disabled_person_code" do
      raw = ["1", "PT"]

      result = DB1.parse(raw)

      assert %DB1{} = result
      assert result.set_id == 1
      assert result.disabled_person_code == "PT"
    end

    test "parses disabled_person_identifier as repeating CX" do
      raw = ["1", "", [["ID123", "", "", ["MRN"]]]]

      result = DB1.parse(raw)

      assert [%HL7v2.Type.CX{id: "ID123"}] = result.disabled_person_identifier
    end

    test "parses disabled_indicator" do
      raw = ["1", "", "", "Y"]

      result = DB1.parse(raw)

      assert result.disabled_indicator == "Y"
    end

    test "parses date fields" do
      raw = ["1", "", "", "Y", "20250101", "20251231", "20260101", "20250601"]

      result = DB1.parse(raw)

      assert result.disability_start_date == ~D[2025-01-01]
      assert result.disability_end_date == ~D[2025-12-31]
      assert result.disability_return_to_work_date == ~D[2026-01-01]
      assert result.disability_unable_to_work_date == ~D[2025-06-01]
    end

    test "parses empty list — all fields nil" do
      result = DB1.parse([])

      assert %DB1{} = result
      assert result.set_id == nil
      assert result.disabled_person_code == nil
      assert result.disability_start_date == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["1", "PT", "", "Y", "20250101", "20251231"]

      encoded = raw |> DB1.parse() |> DB1.encode()
      reparsed = DB1.parse(encoded)

      assert reparsed.set_id == 1
      assert reparsed.disabled_person_code == "PT"
      assert reparsed.disabled_indicator == "Y"
      assert reparsed.disability_start_date == ~D[2025-01-01]
      assert reparsed.disability_end_date == ~D[2025-12-31]
    end

    test "trailing nil fields trimmed" do
      db1 = %DB1{set_id: 1, disabled_person_code: "PT"}

      encoded = DB1.encode(db1)

      assert length(encoded) == 2
    end

    test "encodes all-nil struct to empty list" do
      assert DB1.encode(%DB1{}) == []
    end
  end

  describe "typed parsing integration" do
    test "ADT^A01 with DB1 parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.5.1\r" <>
          "EVN|A01|20260322\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|I\r" <>
          "DB1|1|PT||Y|20250101|20251231\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      db1 = Enum.find(msg.segments, &is_struct(&1, DB1))
      assert %DB1{set_id: 1, disabled_person_code: "PT"} = db1
    end
  end
end
