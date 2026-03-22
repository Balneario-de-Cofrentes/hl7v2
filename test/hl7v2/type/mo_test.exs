defmodule HL7v2.Type.MOTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.MO

  doctest MO

  describe "parse/1" do
    test "parses quantity and denomination" do
      result = MO.parse(["150.00", "USD"])
      assert result.quantity == "150.00"
      assert result.denomination == "USD"
    end

    test "parses quantity only" do
      result = MO.parse(["250"])
      assert result.quantity == "250"
      assert result.denomination == nil
    end

    test "parses empty list" do
      result = MO.parse([])
      assert result.quantity == nil
      assert result.denomination == nil
    end
  end

  describe "encode/1" do
    test "encodes full MO" do
      assert MO.encode(%MO{quantity: "150.00", denomination: "USD"}) == ["150.00", "USD"]
    end

    test "encodes quantity only" do
      assert MO.encode(%MO{quantity: "250"}) == ["250"]
    end

    test "encodes nil" do
      assert MO.encode(nil) == []
    end

    test "encodes empty struct" do
      assert MO.encode(%MO{}) == []
    end
  end

  describe "round-trip" do
    test "full MO round-trips" do
      components = ["150.00", "USD"]
      assert components |> MO.parse() |> MO.encode() == components
    end

    test "quantity-only round-trips" do
      components = ["250"]
      assert components |> MO.parse() |> MO.encode() == components
    end
  end
end
