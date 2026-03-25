defmodule HL7v2.Type.ADTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.AD

  doctest AD

  describe "parse/1" do
    test "parses full address" do
      result =
        AD.parse(["123 Main St", "Suite 100", "Springfield", "IL", "62704", "USA", "H", "Region"])

      assert result.street_address == "123 Main St"
      assert result.other_designation == "Suite 100"
      assert result.city == "Springfield"
      assert result.state_or_province == "IL"
      assert result.zip_or_postal_code == "62704"
      assert result.country == "USA"
      assert result.address_type == "H"
      assert result.other_geographic_designation == "Region"
    end

    test "parses partial address" do
      result = AD.parse(["456 Oak Ave", "", "Portland", "OR"])
      assert result.street_address == "456 Oak Ave"
      assert result.city == "Portland"
      assert result.state_or_province == "OR"
      assert result.country == nil
    end

    test "parses empty list" do
      result = AD.parse([])
      assert result.street_address == nil
    end
  end

  describe "encode/1" do
    test "encodes full address" do
      ad = %AD{
        street_address: "123 Main St",
        city: "Springfield",
        state_or_province: "IL",
        zip_or_postal_code: "62704"
      }

      assert AD.encode(ad) == ["123 Main St", "", "Springfield", "IL", "62704"]
    end

    test "encodes nil" do
      assert AD.encode(nil) == []
    end

    test "encodes empty struct" do
      assert AD.encode(%AD{}) == []
    end
  end

  describe "round-trip" do
    test "full address round-trips" do
      components = ["123 Main St", "Suite 100", "Springfield", "IL", "62704", "USA"]
      assert components |> AD.parse() |> AD.encode() == components
    end
  end
end
