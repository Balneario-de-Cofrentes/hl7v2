defmodule HL7v2.Type.CNNTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.CNN

  doctest HL7v2.Type.CNN

  describe "parse/1" do
    test "parses with ID, family name, given name" do
      result = CNN.parse(["12345", "Smith", "John"])

      assert %CNN{
               id_number: "12345",
               family_name: "Smith",
               given_name: "John"
             } = result
    end

    test "parses all 11 components" do
      components = [
        "12345",
        "Smith",
        "John",
        "Q",
        "JR",
        "DR",
        "MD",
        "PHYS",
        "NPI",
        "2.16.840.1.113883.4.6",
        "ISO"
      ]

      result = CNN.parse(components)

      assert result.id_number == "12345"
      assert result.family_name == "Smith"
      assert result.given_name == "John"
      assert result.second_name == "Q"
      assert result.suffix == "JR"
      assert result.prefix == "DR"
      assert result.degree == "MD"
      assert result.source_table == "PHYS"
      assert result.assigning_authority_namespace_id == "NPI"
      assert result.assigning_authority_universal_id == "2.16.840.1.113883.4.6"
      assert result.assigning_authority_universal_id_type == "ISO"
    end

    test "parses empty list" do
      result = CNN.parse([])

      assert %CNN{} = result
      assert result.id_number == nil
      assert result.family_name == nil
      assert result.given_name == nil
    end

    test "parses with only ID" do
      result = CNN.parse(["99"])

      assert result.id_number == "99"
      assert result.family_name == nil
    end

    test "empty strings become nil" do
      result = CNN.parse(["", "", ""])

      assert result.id_number == nil
      assert result.family_name == nil
      assert result.given_name == nil
    end
  end

  describe "encode/1" do
    test "encodes basic CNN" do
      cnn = %CNN{id_number: "12345", family_name: "Smith", given_name: "John"}

      assert CNN.encode(cnn) == ["12345", "Smith", "John"]
    end

    test "encodes nil returns empty list" do
      assert CNN.encode(nil) == []
    end

    test "encodes empty struct returns empty list" do
      assert CNN.encode(%CNN{}) == []
    end

    test "encodes all 11 components" do
      cnn = %CNN{
        id_number: "12345",
        family_name: "Smith",
        given_name: "John",
        second_name: "Q",
        suffix: "JR",
        prefix: "DR",
        degree: "MD",
        source_table: "PHYS",
        assigning_authority_namespace_id: "NPI",
        assigning_authority_universal_id: "2.16.840.1.113883.4.6",
        assigning_authority_universal_id_type: "ISO"
      }

      encoded = CNN.encode(cnn)

      assert length(encoded) == 11
      assert Enum.at(encoded, 0) == "12345"
      assert Enum.at(encoded, 1) == "Smith"
      assert Enum.at(encoded, 10) == "ISO"
    end

    test "trailing nil fields are trimmed" do
      cnn = %CNN{id_number: "12345"}

      assert CNN.encode(cnn) == ["12345"]
    end

    test "round-trip: parse then encode preserves data" do
      components = [
        "12345",
        "Smith",
        "John",
        "Q",
        "JR",
        "DR",
        "MD",
        "PHYS",
        "NPI",
        "2.16.840.1.113883.4.6",
        "ISO"
      ]

      parsed = CNN.parse(components)
      encoded = CNN.encode(parsed)

      assert encoded == components
    end
  end
end
