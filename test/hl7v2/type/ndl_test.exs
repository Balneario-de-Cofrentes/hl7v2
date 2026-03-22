defmodule HL7v2.Type.NDLTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.NDL
  alias HL7v2.Type.{CNN, HD, TS, DTM}

  doctest HL7v2.Type.NDL

  describe "parse/1" do
    test "parses with name only (CNN sub-components)" do
      result = NDL.parse(["12345&Smith&John"])

      assert %NDL{
               name: %CNN{
                 id_number: "12345",
                 family_name: "Smith",
                 given_name: "John"
               }
             } = result
    end

    test "parses with name and date/time" do
      result = NDL.parse(["12345&Smith&John", "20260315083000", "20260315170000"])

      assert %CNN{id_number: "12345", family_name: "Smith", given_name: "John"} = result.name
      assert %TS{time: %DTM{year: 2026, month: 3, day: 15, hour: 8}} = result.start_date_time
      assert %TS{time: %DTM{year: 2026, month: 3, day: 15, hour: 17}} = result.end_date_time
    end

    test "parses with location fields" do
      result =
        NDL.parse([
          "12345&Smith&John",
          "",
          "",
          "ICU",
          "101",
          "A",
          "HOSP&2.16.840.1.113883.19.4.6&ISO",
          "Active",
          "N",
          "MainBldg",
          "3"
        ])

      assert %CNN{id_number: "12345"} = result.name
      assert result.point_of_care == "ICU"
      assert result.room == "101"
      assert result.bed == "A"

      assert %HD{
               namespace_id: "HOSP",
               universal_id: "2.16.840.1.113883.19.4.6",
               universal_id_type: "ISO"
             } = result.facility

      assert result.location_status == "Active"
      assert result.patient_location_type == "N"
      assert result.building == "MainBldg"
      assert result.floor == "3"
    end

    test "parses empty list" do
      result = NDL.parse([])

      assert %NDL{} = result
      assert result.name == nil
      assert result.start_date_time == nil
      assert result.point_of_care == nil
      assert result.facility == nil
    end

    test "parses with all-nil CNN yields nil name" do
      result = NDL.parse(["", "", "", "ICU"])

      assert result.name == nil
      assert result.point_of_care == "ICU"
    end
  end

  describe "encode/1" do
    test "encodes with name only" do
      ndl = %NDL{
        name: %CNN{id_number: "12345", family_name: "Smith", given_name: "John"}
      }

      assert NDL.encode(ndl) == ["12345&Smith&John"]
    end

    test "encodes nil returns empty list" do
      assert NDL.encode(nil) == []
    end

    test "encodes empty struct returns empty list" do
      assert NDL.encode(%NDL{}) == []
    end

    test "encodes with all fields" do
      ndl = %NDL{
        name: %CNN{id_number: "12345", family_name: "Smith", given_name: "John"},
        start_date_time: %TS{time: %DTM{year: 2026, month: 3, day: 15, hour: 8, minute: 30}},
        end_date_time: %TS{time: %DTM{year: 2026, month: 3, day: 15, hour: 17, minute: 0}},
        point_of_care: "ICU",
        room: "101",
        bed: "A",
        facility: %HD{namespace_id: "HOSP", universal_id: "1.2.3", universal_id_type: "ISO"},
        location_status: "Active",
        patient_location_type: "N",
        building: "Main",
        floor: "3"
      }

      encoded = NDL.encode(ndl)

      assert length(encoded) == 11
      assert Enum.at(encoded, 0) == "12345&Smith&John"
      assert Enum.at(encoded, 1) == "202603150830"
      assert Enum.at(encoded, 2) == "202603151700"
      assert Enum.at(encoded, 3) == "ICU"
      assert Enum.at(encoded, 4) == "101"
      assert Enum.at(encoded, 5) == "A"
      assert Enum.at(encoded, 6) == "HOSP&1.2.3&ISO"
      assert Enum.at(encoded, 7) == "Active"
      assert Enum.at(encoded, 8) == "N"
      assert Enum.at(encoded, 9) == "Main"
      assert Enum.at(encoded, 10) == "3"
    end

    test "trailing nil fields are trimmed" do
      ndl = %NDL{point_of_care: "ICU"}

      encoded = NDL.encode(ndl)
      # Should be ["", "", "", "ICU"]
      assert Enum.at(encoded, 0) == ""
      assert Enum.at(encoded, 3) == "ICU"
      assert length(encoded) == 4
    end

    test "round-trip: parse then encode preserves name" do
      original = %NDL{
        name: %CNN{id_number: "12345", family_name: "Smith", given_name: "John"},
        point_of_care: "ICU",
        room: "101"
      }

      parsed = original |> NDL.encode() |> NDL.parse()

      assert %CNN{id_number: "12345", family_name: "Smith", given_name: "John"} = parsed.name
      assert parsed.point_of_care == "ICU"
      assert parsed.room == "101"
    end

    test "round-trip with date/time" do
      original = %NDL{
        name: %CNN{id_number: "99", family_name: "Jones"},
        start_date_time: %TS{time: %DTM{year: 2026, month: 1, day: 15}},
        facility: %HD{namespace_id: "HOSP"}
      }

      parsed = original |> NDL.encode() |> NDL.parse()

      assert parsed.name.id_number == "99"
      assert parsed.name.family_name == "Jones"
      assert %TS{time: %DTM{year: 2026, month: 1, day: 15}} = parsed.start_date_time
      assert %HD{namespace_id: "HOSP"} = parsed.facility
    end
  end
end
