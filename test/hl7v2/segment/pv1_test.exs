defmodule HL7v2.Segment.PV1Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.PV1
  alias HL7v2.Type.{PL, CX, HD, TS, DTM}

  describe "fields/0" do
    test "returns 52 field definitions" do
      assert length(PV1.fields()) == 52
    end
  end

  describe "segment_id/0" do
    test "returns PV1" do
      assert PV1.segment_id() == "PV1"
    end
  end

  describe "parse/1" do
    test "parses patient_class and assigned_patient_location" do
      raw = build_pv1_fields(%{
        0 => "1",
        1 => "I",
        2 => ["ICU", "101", "A"]
      })

      result = PV1.parse(raw)

      assert %PV1{} = result
      assert result.set_id == 1
      assert result.patient_class == "I"

      assert %PL{} = result.assigned_patient_location
      assert result.assigned_patient_location.point_of_care == "ICU"
      assert result.assigned_patient_location.room == "101"
      assert result.assigned_patient_location.bed == "A"
    end

    test "raw fields (attending_doctor, referring_doctor) preserved as-is" do
      attending = [["Smith", "John", "", "", "", "", "", "", "", "NPI"]]
      referring = "DR^Jones"

      raw = build_pv1_fields(%{
        6 => attending,
        7 => referring
      })

      result = PV1.parse(raw)

      assert result.attending_doctor == attending
      assert result.referring_doctor == referring
    end

    test "visit_number parsed as CX" do
      raw = build_pv1_fields(%{
        18 => ["V12345", "", "", "HOSP", "VN"]
      })

      result = PV1.parse(raw)

      assert %CX{} = result.visit_number
      assert result.visit_number.id == "V12345"
      assert result.visit_number.assigning_authority == %HD{namespace_id: "HOSP"}
      assert result.visit_number.identifier_type_code == "VN"
    end

    test "admit_date_time parsed as TS" do
      raw = build_pv1_fields(%{
        43 => ["20260315120000"]
      })

      result = PV1.parse(raw)

      assert %TS{time: %DTM{year: 2026, month: 3, day: 15, hour: 12, minute: 0, second: 0}} =
               result.admit_date_time
    end

    test "parses empty list — all fields nil" do
      result = PV1.parse([])

      assert %PV1{} = result
      assert result.set_id == nil
      assert result.patient_class == nil
      assert result.assigned_patient_location == nil
      assert result.attending_doctor == nil
      assert result.visit_number == nil
      assert result.admit_date_time == nil
    end
  end

  describe "encode/1" do
    test "round-trip: parse then encode preserves data" do
      raw = build_pv1_fields(%{
        0 => "1",
        1 => "I",
        2 => ["ICU", "101", "A"]
      })

      encoded = raw |> PV1.parse() |> PV1.encode()

      assert Enum.at(encoded, 0) == "1"
      assert Enum.at(encoded, 1) == "I"
      assert Enum.at(encoded, 2) == ["ICU", "101", "A"]
    end

    test "round-trip with raw attending_doctor" do
      raw = build_pv1_fields(%{
        1 => "I",
        6 => "Smith^John"
      })

      encoded = raw |> PV1.parse() |> PV1.encode()

      assert Enum.at(encoded, 1) == "I"
      assert Enum.at(encoded, 6) == "Smith^John"
    end

    test "trailing nil fields are trimmed" do
      pv1 = %PV1{set_id: 1, patient_class: "O"}

      encoded = PV1.encode(pv1)

      assert encoded == ["1", "O"]
    end

    test "encodes all-nil struct to empty list" do
      assert PV1.encode(%PV1{}) == []
    end
  end

  defp build_pv1_fields(overrides) do
    Enum.map(0..51, fn i -> Map.get(overrides, i) end)
  end
end
