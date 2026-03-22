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

  describe "encode/1 with sub-components" do
    test "encode with assigning facility" do
      xcn = %XCN{
        id_number: "12345",
        family_name: %FN{surname: "Smith"},
        given_name: "John",
        assigning_facility: %HD{namespace_id: "FAC", universal_id: "2.3.4", universal_id_type: "ISO"}
      }

      encoded = XCN.encode(xcn)
      assert Enum.at(encoded, 13) == "FAC&2.3.4&ISO"
    end

    test "encode with name context CE" do
      xcn = %XCN{
        id_number: "12345",
        name_context: %CE{identifier: "CTX", text: "Context Text", name_of_coding_system: "99LOCAL"}
      }

      encoded = XCN.encode(xcn)
      assert Enum.at(encoded, 15) == "CTX&Context Text&99LOCAL"
    end

    test "encode with name validity range DR" do
      xcn = %XCN{
        id_number: "12345",
        name_validity_range: %DR{
          range_start: %TS{time: %DTM{year: 2025, month: 1, day: 1}},
          range_end: %TS{time: %DTM{year: 2026, month: 12, day: 31}}
        }
      }

      encoded = XCN.encode(xcn)
      assert Enum.at(encoded, 16) == "20250101&20261231"
    end

    test "encode with effective_date TS" do
      xcn = %XCN{
        id_number: "12345",
        effective_date: %TS{time: %DTM{year: 2025, month: 1, day: 1}}
      }

      encoded = XCN.encode(xcn)
      assert Enum.at(encoded, 18) == "20250101"
    end

    test "encode with expiration_date TS" do
      xcn = %XCN{
        id_number: "12345",
        expiration_date: %TS{time: %DTM{year: 2026, month: 12, day: 31}}
      }

      encoded = XCN.encode(xcn)
      assert Enum.at(encoded, 19) == "20261231"
    end

    test "encode with TS that encodes to empty" do
      xcn = %XCN{
        id_number: "12345",
        effective_date: %TS{},
        professional_suffix: "FACP"
      }

      encoded = XCN.encode(xcn)
      assert Enum.at(encoded, 18) == ""
    end

    test "encode with assigning jurisdiction CWE" do
      xcn = %XCN{
        id_number: "12345",
        assigning_jurisdiction: %CWE{identifier: "STATE", text: "State Code", name_of_coding_system: "99ST"}
      }

      encoded = XCN.encode(xcn)
      assert Enum.at(encoded, 21) == "STATE&State Code&99ST"
    end

    test "encode with assigning agency CWE" do
      xcn = %XCN{
        id_number: "12345",
        assigning_agency: %CWE{identifier: "DEPT", text: "Department"}
      }

      encoded = XCN.encode(xcn)
      assert Enum.at(encoded, 22) == "DEPT&Department"
    end

    test "encode full round-trip with all sub-component fields" do
      original = %XCN{
        id_number: "12345",
        family_name: %FN{surname: "Smith", own_surname_prefix: "Van"},
        given_name: "John",
        second_name: "Q",
        suffix: "JR",
        prefix: "DR",
        degree: "MD",
        source_table: "PHYS",
        assigning_authority: %HD{namespace_id: "MRN", universal_id: "1.2.3", universal_id_type: "ISO"},
        name_type_code: "L",
        identifier_check_digit: "1",
        check_digit_scheme: "M11",
        identifier_type_code: "NPI",
        assigning_facility: %HD{namespace_id: "FAC"},
        name_representation_code: "A",
        name_assembly_order: "G",
        professional_suffix: "FACP"
      }

      parsed = original |> XCN.encode() |> XCN.parse()

      assert parsed.id_number == "12345"
      assert parsed.family_name == %FN{surname: "Smith", own_surname_prefix: "Van"}
      assert parsed.given_name == "John"
      assert parsed.second_name == "Q"
      assert parsed.suffix == "JR"
      assert parsed.prefix == "DR"
      assert parsed.degree == "MD"
      assert parsed.source_table == "PHYS"
      assert parsed.assigning_authority.namespace_id == "MRN"
      assert parsed.name_type_code == "L"
      assert parsed.identifier_type_code == "NPI"
      assert parsed.assigning_facility.namespace_id == "FAC"
      assert parsed.name_representation_code == "A"
      assert parsed.name_assembly_order == "G"
      assert parsed.professional_suffix == "FACP"
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
