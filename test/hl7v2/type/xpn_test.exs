defmodule HL7v2.Type.XPNTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.XPN
  alias HL7v2.Type.{FN, CE, DR, TS, DTM}

  doctest XPN

  describe "parse/1" do
    test "parses basic name" do
      result = XPN.parse(["Smith", "John"])

      assert %XPN{
               family_name: %FN{surname: "Smith"},
               given_name: "John"
             } = result
    end

    test "parses with family name sub-components" do
      result = XPN.parse(["Smith&Van", "John"])

      assert result.family_name == %FN{surname: "Smith", own_surname_prefix: "Van"}
    end

    test "parses with name context CE sub-component" do
      result =
        XPN.parse([
          "Smith",
          "John",
          "",
          "",
          "",
          "",
          "L",
          "",
          "CTX&Context Text&99LOCAL"
        ])

      assert result.name_type_code == "L"
      assert %CE{identifier: "CTX", text: "Context Text"} = result.name_context
    end

    test "parses with name validity range DR sub-component" do
      result =
        XPN.parse([
          "Smith",
          "John",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "20250101&20261231"
        ])

      assert %DR{} = result.name_validity_range
      assert %TS{time: %DTM{year: 2025}} = result.name_validity_range.range_start
      assert %TS{time: %DTM{year: 2026}} = result.name_validity_range.range_end
    end

    test "parses with effective and expiration dates" do
      result =
        XPN.parse([
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
          "20250101",
          "20261231"
        ])

      assert %TS{time: %DTM{year: 2025}} = result.effective_date
      assert %TS{time: %DTM{year: 2026}} = result.expiration_date
    end

    test "parses with professional suffix" do
      result =
        XPN.parse([
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
          "",
          "",
          "FACP"
        ])

      assert result.professional_suffix == "FACP"
    end

    test "parses with all simple fields" do
      result = XPN.parse(["Smith", "John", "Q", "JR", "DR", "MD", "L", "A"])

      assert result.second_name == "Q"
      assert result.suffix == "JR"
      assert result.prefix == "DR"
      assert result.degree == "MD"
      assert result.name_type_code == "L"
      assert result.name_representation_code == "A"
    end

    test "parses with name assembly order" do
      result =
        XPN.parse([
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
          "G"
        ])

      assert result.name_assembly_order == "G"
    end

    test "empty string sub-components parse to nil" do
      result = XPN.parse(["Smith", "John", "", "", "", "", "", "", "", ""])

      assert result.name_context == nil
      assert result.name_validity_range == nil
    end
  end

  describe "encode/1" do
    test "encodes nil returns empty list" do
      assert XPN.encode(nil) == []
    end

    test "encodes empty struct" do
      assert XPN.encode(%XPN{}) == []
    end

    test "encodes basic name" do
      xpn = %XPN{family_name: %FN{surname: "Smith"}, given_name: "John"}

      assert XPN.encode(xpn) == ["Smith", "John"]
    end

    test "encodes with family name sub-components" do
      xpn = %XPN{
        family_name: %FN{surname: "Smith", own_surname_prefix: "Van"},
        given_name: "John"
      }

      encoded = XPN.encode(xpn)
      assert Enum.at(encoded, 0) == "Smith&Van"
    end

    test "encodes with nil family name" do
      xpn = %XPN{given_name: "John"}

      encoded = XPN.encode(xpn)
      assert Enum.at(encoded, 0) == ""
      assert Enum.at(encoded, 1) == "John"
    end

    test "encodes with name context CE" do
      xpn = %XPN{
        family_name: %FN{surname: "Smith"},
        given_name: "John",
        name_context: %CE{
          identifier: "CTX",
          text: "Context Text",
          name_of_coding_system: "99LOCAL"
        }
      }

      encoded = XPN.encode(xpn)
      assert Enum.at(encoded, 8) == "CTX&Context Text&99LOCAL"
    end

    test "encodes with nil name context" do
      xpn = %XPN{
        family_name: %FN{surname: "Smith"},
        given_name: "John",
        name_type_code: "L",
        name_assembly_order: "G"
      }

      encoded = XPN.encode(xpn)
      assert Enum.at(encoded, 8) == ""
    end

    test "encodes with name validity range DR" do
      xpn = %XPN{
        family_name: %FN{surname: "Smith"},
        given_name: "John",
        name_validity_range: %DR{
          range_start: %TS{time: %DTM{year: 2025, month: 1, day: 1}},
          range_end: %TS{time: %DTM{year: 2026, month: 12, day: 31}}
        }
      }

      encoded = XPN.encode(xpn)
      assert Enum.at(encoded, 9) == "20250101&20261231"
    end

    test "encodes with nil name validity range" do
      xpn = %XPN{
        family_name: %FN{surname: "Smith"},
        name_assembly_order: "G"
      }

      encoded = XPN.encode(xpn)
      assert Enum.at(encoded, 9) == ""
    end

    test "encodes with effective and expiration TS dates" do
      xpn = %XPN{
        family_name: %FN{surname: "Smith"},
        given_name: "John",
        effective_date: %TS{time: %DTM{year: 2025, month: 1, day: 1}},
        expiration_date: %TS{time: %DTM{year: 2026, month: 12, day: 31}}
      }

      encoded = XPN.encode(xpn)
      assert Enum.at(encoded, 11) == "20250101"
      assert Enum.at(encoded, 12) == "20261231"
    end

    test "encodes with nil TS returns empty string" do
      xpn = %XPN{
        family_name: %FN{surname: "Smith"},
        professional_suffix: "FACP"
      }

      encoded = XPN.encode(xpn)
      assert Enum.at(encoded, 11) == ""
      assert Enum.at(encoded, 12) == ""
    end

    test "encodes TS with empty encode list" do
      xpn = %XPN{
        family_name: %FN{surname: "Smith"},
        effective_date: %TS{},
        professional_suffix: "FACP"
      }

      encoded = XPN.encode(xpn)
      assert Enum.at(encoded, 11) == ""
    end

    test "encode round-trip preserves all fields" do
      original = %XPN{
        family_name: %FN{surname: "Smith", own_surname_prefix: "Van"},
        given_name: "John",
        second_name: "Q",
        suffix: "JR",
        prefix: "DR",
        degree: "MD",
        name_type_code: "L",
        name_representation_code: "A",
        name_assembly_order: "G",
        professional_suffix: "FACP"
      }

      parsed = original |> XPN.encode() |> XPN.parse()

      assert parsed.family_name == %FN{surname: "Smith", own_surname_prefix: "Van"}
      assert parsed.given_name == "John"
      assert parsed.second_name == "Q"
      assert parsed.suffix == "JR"
      assert parsed.prefix == "DR"
      assert parsed.degree == "MD"
      assert parsed.name_type_code == "L"
      assert parsed.name_representation_code == "A"
      assert parsed.name_assembly_order == "G"
      assert parsed.professional_suffix == "FACP"
    end
  end
end
