defmodule HL7v2.Type.SPSTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.SPS
  alias HL7v2.Type.CWE

  doctest SPS

  describe "parse/1" do
    test "parses full SPS with specimen source and collection method" do
      result = SPS.parse(["BLD&Blood&HL70070", "", "Venipuncture"])

      assert %CWE{
               identifier: "BLD",
               text: "Blood",
               name_of_coding_system: "HL70070"
             } = result.specimen_source_name_or_code

      assert result.additives == nil
      assert result.specimen_collection_method == "Venipuncture"
    end

    test "parses with all CWE components" do
      result =
        SPS.parse([
          "BLD&Blood&HL70070",
          "EDTA&EDTA&HL70371",
          "Venipuncture",
          "LACF&Left Antecubital Fossa&HL70163",
          "ANT&Anterior&HL70495",
          "MOD1&modifier",
          "P&Patient&HL70369"
        ])

      assert %CWE{identifier: "BLD"} = result.specimen_source_name_or_code
      assert %CWE{identifier: "EDTA"} = result.additives
      assert result.specimen_collection_method == "Venipuncture"
      assert %CWE{identifier: "LACF"} = result.body_site
      assert %CWE{identifier: "ANT"} = result.site_modifier
      assert %CWE{identifier: "MOD1"} = result.collection_method_modifier_code
      assert %CWE{identifier: "P"} = result.specimen_role
    end

    test "parses with simple identifier" do
      result = SPS.parse(["BLD"])
      assert %CWE{identifier: "BLD"} = result.specimen_source_name_or_code
    end

    test "parses empty list" do
      result = SPS.parse([])
      assert result.specimen_source_name_or_code == nil
      assert result.additives == nil
      assert result.specimen_collection_method == nil
      assert result.body_site == nil
      assert result.site_modifier == nil
      assert result.collection_method_modifier_code == nil
      assert result.specimen_role == nil
    end
  end

  describe "encode/1" do
    test "encodes full SPS" do
      sps = %SPS{
        specimen_source_name_or_code: %CWE{
          identifier: "BLD",
          text: "Blood",
          name_of_coding_system: "HL70070"
        },
        specimen_collection_method: "Venipuncture"
      }

      assert SPS.encode(sps) == ["BLD&Blood&HL70070", "", "Venipuncture"]
    end

    test "encodes with body site" do
      sps = %SPS{
        specimen_source_name_or_code: %CWE{identifier: "BLD"},
        body_site: %CWE{identifier: "LACF", text: "Left Antecubital Fossa"}
      }

      assert SPS.encode(sps) == ["BLD", "", "", "LACF&Left Antecubital Fossa"]
    end

    test "encodes nil" do
      assert SPS.encode(nil) == []
    end

    test "encodes empty struct" do
      assert SPS.encode(%SPS{}) == []
    end
  end

  describe "round-trip" do
    test "full SPS round-trips" do
      components = ["BLD&Blood&HL70070", "", "Venipuncture"]
      assert components |> SPS.parse() |> SPS.encode() == components
    end

    test "specimen source only round-trips" do
      components = ["BLD&Blood"]
      assert components |> SPS.parse() |> SPS.encode() == components
    end

    test "all components round-trip" do
      components = [
        "BLD&Blood&HL70070",
        "EDTA&EDTA&HL70371",
        "Venipuncture",
        "LACF&Left Antecubital Fossa&HL70163",
        "ANT&Anterior&HL70495",
        "MOD1&modifier",
        "P&Patient&HL70369"
      ]

      assert components |> SPS.parse() |> SPS.encode() == components
    end
  end
end
