defmodule HL7v2.Type.CPTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.CP
  alias HL7v2.Type.{MO, CE}

  doctest CP

  describe "parse/1" do
    test "parses price with type" do
      result = CP.parse(["100.00&USD", "UP"])
      assert %MO{quantity: "100.00", denomination: "USD"} = result.price
      assert result.price_type == "UP"
    end

    test "parses price only" do
      result = CP.parse(["50"])
      assert %MO{quantity: "50"} = result.price
      assert result.price_type == nil
    end

    test "parses full CP with range" do
      result = CP.parse(["100.00&USD", "UP", "1", "10", "day&Day&UCUM", "F"])
      assert %MO{quantity: "100.00", denomination: "USD"} = result.price
      assert result.price_type == "UP"
      assert result.from_value == "1"
      assert result.to_value == "10"

      assert %CE{identifier: "day", text: "Day", name_of_coding_system: "UCUM"} =
               result.range_units

      assert result.range_type == "F"
    end

    test "parses empty list" do
      result = CP.parse([])
      assert result.price == nil
      assert result.price_type == nil
      assert result.from_value == nil
      assert result.to_value == nil
      assert result.range_units == nil
      assert result.range_type == nil
    end
  end

  describe "encode/1" do
    test "encodes price with type" do
      cp = %CP{price: %MO{quantity: "100.00", denomination: "USD"}, price_type: "UP"}
      assert CP.encode(cp) == ["100.00&USD", "UP"]
    end

    test "encodes price only" do
      cp = %CP{price: %MO{quantity: "50"}}
      assert CP.encode(cp) == ["50"]
    end

    test "encodes full CP" do
      cp = %CP{
        price: %MO{quantity: "100.00", denomination: "USD"},
        price_type: "UP",
        from_value: "1",
        to_value: "10",
        range_units: %CE{identifier: "day", text: "Day", name_of_coding_system: "UCUM"},
        range_type: "F"
      }

      assert CP.encode(cp) == ["100.00&USD", "UP", "1", "10", "day&Day&UCUM", "F"]
    end

    test "encodes nil" do
      assert CP.encode(nil) == []
    end

    test "encodes empty struct" do
      assert CP.encode(%CP{}) == []
    end
  end

  describe "round-trip" do
    test "price with type round-trips" do
      components = ["100.00&USD", "UP"]
      assert components |> CP.parse() |> CP.encode() == components
    end

    test "full CP round-trips" do
      components = ["100.00&USD", "UP", "1", "10", "day&Day&UCUM", "F"]
      assert components |> CP.parse() |> CP.encode() == components
    end

    test "price-only round-trips" do
      components = ["50"]
      assert components |> CP.parse() |> CP.encode() == components
    end
  end
end
