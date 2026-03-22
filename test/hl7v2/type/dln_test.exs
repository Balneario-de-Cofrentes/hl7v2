defmodule HL7v2.Type.DLNTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.DLN

  doctest DLN

  describe "parse/1" do
    test "parses all three components" do
      result = DLN.parse(["S12345678", "CA", "20280101"])
      assert result.license_number == "S12345678"
      assert result.issuing_state_province_country == "CA"
      assert result.expiration_date == ~D[2028-01-01]
    end

    test "parses license number and issuing authority" do
      result = DLN.parse(["S12345678", "CA"])
      assert result.license_number == "S12345678"
      assert result.issuing_state_province_country == "CA"
      assert result.expiration_date == nil
    end

    test "parses license number only" do
      result = DLN.parse(["S12345678"])
      assert result.license_number == "S12345678"
      assert result.issuing_state_province_country == nil
      assert result.expiration_date == nil
    end

    test "parses partial date" do
      result = DLN.parse(["S12345678", "CA", "202801"])
      assert result.expiration_date == %HL7v2.Type.DT{year: 2028, month: 1}
    end

    test "parses empty list" do
      result = DLN.parse([])
      assert result.license_number == nil
      assert result.issuing_state_province_country == nil
      assert result.expiration_date == nil
    end
  end

  describe "encode/1" do
    test "encodes all components" do
      dln = %DLN{
        license_number: "S12345678",
        issuing_state_province_country: "CA",
        expiration_date: ~D[2028-01-01]
      }

      assert DLN.encode(dln) == ["S12345678", "CA", "20280101"]
    end

    test "encodes license number only" do
      assert DLN.encode(%DLN{license_number: "S12345678"}) == ["S12345678"]
    end

    test "encodes nil" do
      assert DLN.encode(nil) == []
    end

    test "encodes empty struct" do
      assert DLN.encode(%DLN{}) == []
    end
  end

  describe "round-trip" do
    test "full DLN round-trips" do
      components = ["S12345678", "CA", "20280101"]
      assert components |> DLN.parse() |> DLN.encode() == components
    end

    test "license-only round-trips" do
      components = ["S12345678"]
      assert components |> DLN.parse() |> DLN.encode() == components
    end

    test "license and state round-trips" do
      components = ["S12345678", "CA"]
      assert components |> DLN.parse() |> DLN.encode() == components
    end
  end
end
