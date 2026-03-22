defmodule HL7v2.Type.PLTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.PL
  alias HL7v2.Type.{HD, EI}

  doctest PL

  describe "parse/1" do
    test "parses all 11 components" do
      result =
        PL.parse([
          "ICU",
          "101",
          "A",
          "HOSP&2.16.840.1.113883.19.4.6&ISO",
          "active",
          "N",
          "Main",
          "3",
          "ICU Room 101 Bed A",
          "LOC001&HOSP&1.2.3&ISO",
          "AUTH&2.3.4&ISO"
        ])

      assert result.point_of_care == "ICU"
      assert result.room == "101"
      assert result.bed == "A"
      assert %HD{namespace_id: "HOSP"} = result.facility
      assert result.location_status == "active"
      assert result.person_location_type == "N"
      assert result.building == "Main"
      assert result.floor == "3"
      assert result.location_description == "ICU Room 101 Bed A"
      assert %EI{entity_identifier: "LOC001"} = result.comprehensive_location_identifier
      assert %HD{namespace_id: "AUTH"} = result.assigning_authority_for_location
    end

    test "parses with empty sub-component HD returns nil" do
      result = PL.parse(["ICU", "", "", ""])

      assert result.point_of_care == "ICU"
      assert result.facility == nil
    end

    test "parses with empty sub-component EI returns nil" do
      result = PL.parse(["ICU", "", "", "", "", "", "", "", "", ""])

      assert result.comprehensive_location_identifier == nil
    end

    test "parses empty list" do
      assert %PL{} = PL.parse([])
    end
  end

  describe "encode/1" do
    test "encodes nil returns empty list" do
      assert PL.encode(nil) == []
    end

    test "encodes empty struct" do
      assert PL.encode(%PL{}) == []
    end

    test "encodes with facility HD" do
      pl = %PL{
        point_of_care: "ICU",
        facility: %HD{namespace_id: "HOSP", universal_id: "1.2.3", universal_id_type: "ISO"}
      }

      encoded = PL.encode(pl)
      assert Enum.at(encoded, 0) == "ICU"
      assert Enum.at(encoded, 3) == "HOSP&1.2.3&ISO"
    end

    test "encodes with nil facility (trailing trimmed)" do
      pl = %PL{point_of_care: "ICU", room: "101"}

      encoded = PL.encode(pl)
      # Only two non-empty values, trailing nils are trimmed
      assert encoded == ["ICU", "101"]
    end

    test "encodes with nil facility mid-field" do
      pl = %PL{point_of_care: "ICU", room: "101", person_location_type: "N"}

      encoded = PL.encode(pl)
      assert Enum.at(encoded, 0) == "ICU"
      assert Enum.at(encoded, 1) == "101"
      assert Enum.at(encoded, 3) == ""
      assert Enum.at(encoded, 5) == "N"
    end

    test "encodes with comprehensive location identifier EI" do
      pl = %PL{
        point_of_care: "ICU",
        comprehensive_location_identifier: %EI{
          entity_identifier: "LOC001",
          namespace_id: "HOSP",
          universal_id: "1.2.3",
          universal_id_type: "ISO"
        }
      }

      encoded = PL.encode(pl)
      assert Enum.at(encoded, 9) == "LOC001&HOSP&1.2.3&ISO"
    end

    test "encodes with nil EI returns empty string" do
      pl = %PL{
        point_of_care: "ICU",
        assigning_authority_for_location: %HD{namespace_id: "AUTH"}
      }

      encoded = PL.encode(pl)
      assert Enum.at(encoded, 9) == ""
    end

    test "encodes with assigning authority for location HD" do
      pl = %PL{
        point_of_care: "ICU",
        assigning_authority_for_location: %HD{namespace_id: "AUTH"}
      }

      encoded = PL.encode(pl)
      assert Enum.at(encoded, 10) == "AUTH"
    end

    test "encode round-trip preserves data" do
      original = %PL{
        point_of_care: "ICU",
        room: "101",
        bed: "A",
        facility: %HD{namespace_id: "HOSP"},
        person_location_type: "N"
      }

      parsed = original |> PL.encode() |> PL.parse()

      assert parsed.point_of_care == "ICU"
      assert parsed.room == "101"
      assert parsed.bed == "A"
      assert parsed.facility.namespace_id == "HOSP"
      assert parsed.person_location_type == "N"
    end
  end
end
