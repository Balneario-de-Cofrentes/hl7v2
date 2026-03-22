defmodule HL7v2.Type.SADTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.SAD

  doctest SAD

  describe "parse/1" do
    test "parses all three sub-components" do
      result = SAD.parse(["123 Main St", "Main St", "123"])

      assert result.street_or_mailing_address == "123 Main St"
      assert result.street_name == "Main St"
      assert result.dwelling_number == "123"
    end

    test "parses street address only" do
      result = SAD.parse(["123 Main St"])

      assert result.street_or_mailing_address == "123 Main St"
      assert result.street_name == nil
      assert result.dwelling_number == nil
    end

    test "parses empty list" do
      result = SAD.parse([])
      assert %SAD{} = result
    end
  end

  describe "encode/1" do
    test "encodes nil returns empty list" do
      assert SAD.encode(nil) == []
    end

    test "encodes empty struct" do
      assert SAD.encode(%SAD{}) == []
    end

    test "encodes all three sub-components" do
      sad = %SAD{
        street_or_mailing_address: "123 Main St",
        street_name: "Main St",
        dwelling_number: "123"
      }

      assert SAD.encode(sad) == ["123 Main St", "Main St", "123"]
    end

    test "encodes with street address only (trims trailing)" do
      sad = %SAD{street_or_mailing_address: "123 Main St"}
      assert SAD.encode(sad) == ["123 Main St"]
    end

    test "encode round-trip" do
      original = %SAD{
        street_or_mailing_address: "123 Main St",
        street_name: "Main St",
        dwelling_number: "123"
      }

      parsed = original |> SAD.encode() |> SAD.parse()
      assert parsed == original
    end
  end
end
