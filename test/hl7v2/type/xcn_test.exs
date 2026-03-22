defmodule HL7v2.Type.XCNTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.XCN
  alias HL7v2.Type.{FN, HD, CE, CWE, DR, TS, DTM}
  alias HL7v2.Segment.PV1

  doctest HL7v2.Type.XCN

  describe "parse/1" do
    test "parses with ID number, family name, given name" do
      result = XCN.parse(["12345", "Smith", "John"])

      assert %XCN{
               id_number: "12345",
               family_name: %FN{surname: "Smith"},
               given_name: "John"
             } = result
    end

    test "parses with assigning authority (HD sub-components)" do
      result =
        XCN.parse([
          "12345",
          "Smith",
          "John",
          "",
          "",
          "",
          "",
          "",
          "MRN&1.2.3&ISO"
        ])

      assert %XCN{
               id_number: "12345",
               family_name: %FN{surname: "Smith"},
               given_name: "John",
               assigning_authority: %HD{
                 namespace_id: "MRN",
                 universal_id: "1.2.3",
                 universal_id_type: "ISO"
               }
             } = result
    end

    test "parses with identifier_type_code" do
      result =
        XCN.parse([
          "12345",
          "Smith",
          "John",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "NPI"
        ])

      assert result.identifier_type_code == "NPI"
    end

    test "parse empty list" do
      result = XCN.parse([])

      assert %XCN{} = result
      assert result.id_number == nil
      assert result.family_name == nil
      assert result.given_name == nil
      assert result.assigning_authority == nil
      assert result.identifier_type_code == nil
    end

    test "parses with full 23 components" do
      components = [
        "12345",
        "Smith&Van",
        "John",
        "Q",
        "JR",
        "DR",
        "MD",
        "PHYS",
        "MRN&1.2.3&ISO",
        "L",
        "1",
        "M11",
        "NPI",
        "FAC&2.3.4&ISO",
        "A",
        "CTX&Context Text&99LOCAL",
        "20250101&20261231",
        "G",
        "20250101",
        "20261231",
        "FACP",
        "STATE&State Code&99ST",
        "DEPT&Department&99DP"
      ]

      result = XCN.parse(components)

      assert result.id_number == "12345"
      assert %FN{surname: "Smith", own_surname_prefix: "Van"} = result.family_name
      assert result.given_name == "John"
      assert result.second_name == "Q"
      assert result.suffix == "JR"
      assert result.prefix == "DR"
      assert result.degree == "MD"
      assert result.source_table == "PHYS"

      assert %HD{namespace_id: "MRN", universal_id: "1.2.3", universal_id_type: "ISO"} =
               result.assigning_authority

      assert result.name_type_code == "L"
      assert result.identifier_check_digit == "1"
      assert result.check_digit_scheme == "M11"
      assert result.identifier_type_code == "NPI"

      assert %HD{namespace_id: "FAC", universal_id: "2.3.4", universal_id_type: "ISO"} =
               result.assigning_facility

      assert result.name_representation_code == "A"
      assert %CE{identifier: "CTX", text: "Context Text"} = result.name_context
      assert %DR{} = result.name_validity_range
      assert result.name_assembly_order == "G"
      assert %TS{time: %DTM{year: 2025}} = result.effective_date
      assert %TS{time: %DTM{year: 2026}} = result.expiration_date
      assert result.professional_suffix == "FACP"
      assert %CWE{identifier: "STATE", text: "State Code"} = result.assigning_jurisdiction
      assert %CWE{identifier: "DEPT", text: "Department"} = result.assigning_agency
    end
  end

  describe "encode/1" do
    test "encode round-trip" do
      original = %XCN{
        id_number: "12345",
        family_name: %FN{surname: "Smith"},
        given_name: "John",
        identifier_type_code: "NPI"
      }

      encoded = XCN.encode(original)
      parsed = XCN.parse(encoded)

      assert parsed.id_number == "12345"
      assert parsed.family_name == %FN{surname: "Smith"}
      assert parsed.given_name == "John"
      assert parsed.identifier_type_code == "NPI"
    end

    test "encode nil returns empty list" do
      assert XCN.encode(nil) == []
    end

    test "encode empty struct returns empty list" do
      assert XCN.encode(%XCN{}) == []
    end

    test "encode with assigning authority" do
      xcn = %XCN{
        id_number: "12345",
        family_name: %FN{surname: "Smith"},
        given_name: "John",
        assigning_authority: %HD{
          namespace_id: "MRN",
          universal_id: "1.2.3",
          universal_id_type: "ISO"
        }
      }

      encoded = XCN.encode(xcn)

      assert Enum.at(encoded, 0) == "12345"
      assert Enum.at(encoded, 1) == "Smith"
      assert Enum.at(encoded, 2) == "John"
      assert Enum.at(encoded, 8) == "MRN&1.2.3&ISO"
    end
  end

  describe "field in segment" do
    test "PV1 attending_doctor parses as XCN struct" do
      raw =
        Enum.map(0..51, fn
          6 ->
            [
              "1234",
              "Smith",
              "John",
              "",
              "",
              "",
              "",
              "",
              "NPI&2.16.840.1.113883.4.6&ISO",
              "",
              "",
              "",
              "NPI"
            ]

          _ ->
            nil
        end)

      result = PV1.parse(raw)

      assert [%XCN{} = attending] = result.attending_doctor
      assert attending.id_number == "1234"
      assert attending.family_name == %FN{surname: "Smith"}
      assert attending.given_name == "John"
      assert %HD{namespace_id: "NPI"} = attending.assigning_authority
      assert attending.identifier_type_code == "NPI"
    end
  end
end
