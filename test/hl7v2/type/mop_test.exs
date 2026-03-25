defmodule HL7v2.Type.MOPTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.MOP

  doctest MOP

  describe "parse/1" do
    test "parses amount" do
      result = MOP.parse(["AT", "150.00"])
      assert result.money_or_percentage_indicator == "AT"
      assert result.money_or_percentage_quantity == "150.00"
    end

    test "parses percentage" do
      result = MOP.parse(["PC", "80"])
      assert result.money_or_percentage_indicator == "PC"
    end

    test "parses empty list" do
      assert MOP.parse([]).money_or_percentage_indicator == nil
    end
  end

  describe "encode/1" do
    test "encodes MOP" do
      mop = %MOP{money_or_percentage_indicator: "AT", money_or_percentage_quantity: "150.00"}
      assert MOP.encode(mop) == ["AT", "150.00"]
    end

    test "encodes nil" do
      assert MOP.encode(nil) == []
    end
  end

  describe "round-trip" do
    test "round-trips" do
      components = ["AT", "150.00"]
      assert components |> MOP.parse() |> MOP.encode() == components
    end
  end
end
