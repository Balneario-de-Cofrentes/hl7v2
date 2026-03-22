defmodule HL7v2.Type.CQTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.CQ
  alias HL7v2.Type.CE

  doctest CQ

  describe "parse/1" do
    test "parses quantity with units" do
      result = CQ.parse(["10", "mL&milliliter&UCUM"])
      assert result.quantity == "10"

      assert %CE{identifier: "mL", text: "milliliter", name_of_coding_system: "UCUM"} =
               result.units
    end

    test "parses quantity only" do
      result = CQ.parse(["5"])
      assert result.quantity == "5"
      assert result.units == nil
    end

    test "parses with simple unit code" do
      result = CQ.parse(["100", "mg"])
      assert result.quantity == "100"
      assert %CE{identifier: "mg"} = result.units
    end

    test "parses empty list" do
      result = CQ.parse([])
      assert result.quantity == nil
      assert result.units == nil
    end
  end

  describe "encode/1" do
    test "encodes full CQ" do
      cq = %CQ{
        quantity: "10",
        units: %CE{identifier: "mL", text: "milliliter", name_of_coding_system: "UCUM"}
      }

      assert CQ.encode(cq) == ["10", "mL&milliliter&UCUM"]
    end

    test "encodes quantity only" do
      assert CQ.encode(%CQ{quantity: "5"}) == ["5"]
    end

    test "encodes nil" do
      assert CQ.encode(nil) == []
    end

    test "encodes empty struct" do
      assert CQ.encode(%CQ{}) == []
    end
  end

  describe "round-trip" do
    test "full CQ round-trips" do
      components = ["10", "mL&milliliter&UCUM"]
      assert components |> CQ.parse() |> CQ.encode() == components
    end

    test "quantity-only round-trips" do
      components = ["5"]
      assert components |> CQ.parse() |> CQ.encode() == components
    end
  end
end
