defmodule HL7v2.Type.XONTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.XON
  alias HL7v2.Type.HD

  doctest XON

  describe "parse/1" do
    test "parses all 10 components" do
      result =
        XON.parse([
          "General Hospital",
          "L",
          "12345",
          "5",
          "M11",
          "HOSP&2.16.840.1.113883.19.4.6&ISO",
          "XX",
          "FAC&1.2.3&ISO",
          "A",
          "GH001"
        ])

      assert result.organization_name == "General Hospital"
      assert result.organization_name_type_code == "L"
      assert result.id_number == "12345"
      assert result.check_digit == "5"
      assert result.check_digit_scheme == "M11"

      assert %HD{
               namespace_id: "HOSP",
               universal_id: "2.16.840.1.113883.19.4.6",
               universal_id_type: "ISO"
             } = result.assigning_authority

      assert result.identifier_type_code == "XX"

      assert %HD{namespace_id: "FAC", universal_id: "1.2.3", universal_id_type: "ISO"} =
               result.assigning_facility

      assert result.name_representation_code == "A"
      assert result.organization_identifier == "GH001"
    end

    test "parses with only organization name" do
      result = XON.parse(["General Hospital"])

      assert result.organization_name == "General Hospital"
      assert result.assigning_authority == nil
    end

    test "parses empty list" do
      assert %XON{} = XON.parse([])
    end

    test "parses with empty sub-component HD returns nil" do
      result = XON.parse(["Hospital", "", "", "", "", "", "", ""])

      assert result.organization_name == "Hospital"
      assert result.assigning_authority == nil
      assert result.assigning_facility == nil
    end
  end

  describe "encode/1" do
    test "encodes nil returns empty list" do
      assert XON.encode(nil) == []
    end

    test "encodes empty struct" do
      assert XON.encode(%XON{}) == []
    end

    test "encodes with organization name only" do
      xon = %XON{organization_name: "General Hospital", organization_name_type_code: "L"}

      assert XON.encode(xon) == ["General Hospital", "L"]
    end

    test "encodes with assigning authority HD" do
      xon = %XON{
        organization_name: "General Hospital",
        organization_name_type_code: "L",
        assigning_authority: %HD{
          namespace_id: "HOSP",
          universal_id: "2.16.840.1.113883.19.4.6",
          universal_id_type: "ISO"
        },
        identifier_type_code: "XX",
        organization_identifier: "GH001"
      }

      encoded = XON.encode(xon)

      assert Enum.at(encoded, 0) == "General Hospital"
      assert Enum.at(encoded, 1) == "L"
      assert Enum.at(encoded, 5) == "HOSP&2.16.840.1.113883.19.4.6&ISO"
      assert Enum.at(encoded, 6) == "XX"
      assert Enum.at(encoded, 9) == "GH001"
    end

    test "encodes with assigning facility HD" do
      xon = %XON{
        organization_name: "Lab",
        assigning_facility: %HD{namespace_id: "FAC"}
      }

      encoded = XON.encode(xon)
      assert Enum.at(encoded, 7) == "FAC"
    end

    test "encode round-trip preserves data" do
      original = %XON{
        organization_name: "General Hospital",
        organization_name_type_code: "L",
        assigning_authority: %HD{namespace_id: "HOSP", universal_id: "1.2.3", universal_id_type: "ISO"},
        identifier_type_code: "XX",
        organization_identifier: "GH001"
      }

      parsed = original |> XON.encode() |> XON.parse()

      assert parsed.organization_name == "General Hospital"
      assert parsed.organization_name_type_code == "L"
      assert parsed.assigning_authority.namespace_id == "HOSP"
      assert parsed.assigning_authority.universal_id == "1.2.3"
      assert parsed.identifier_type_code == "XX"
      assert parsed.organization_identifier == "GH001"
    end
  end
end
