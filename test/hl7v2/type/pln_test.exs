defmodule HL7v2.Type.PLNTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.PLN
  alias HL7v2.Type.DT

  doctest PLN

  describe "parse/1" do
    test "parses full PLN with expiration date" do
      result = PLN.parse(["A12345", "MD", "CA", "20281231"])
      assert result.id_number == "A12345"
      assert result.type_of_id_number == "MD"
      assert result.state_other_qualifying_information == "CA"
      assert result.expiration_date == ~D[2028-12-31]
    end

    test "parses PLN without expiration date" do
      result = PLN.parse(["DEA98765", "DEA"])
      assert result.id_number == "DEA98765"
      assert result.type_of_id_number == "DEA"
      assert result.state_other_qualifying_information == nil
      assert result.expiration_date == nil
    end

    test "parses PLN with partial date (year-month)" do
      result = PLN.parse(["NP111", "NP", "NY", "202812"])
      assert result.id_number == "NP111"
      assert result.type_of_id_number == "NP"
      assert result.state_other_qualifying_information == "NY"
      assert %DT{year: 2028, month: 12, day: nil} = result.expiration_date
    end

    test "parses PLN with ID number only" do
      result = PLN.parse(["LICENSE123"])
      assert result.id_number == "LICENSE123"
      assert result.type_of_id_number == nil
    end

    test "parses empty list" do
      result = PLN.parse([])
      assert result.id_number == nil
      assert result.type_of_id_number == nil
      assert result.state_other_qualifying_information == nil
      assert result.expiration_date == nil
    end
  end

  describe "encode/1" do
    test "encodes full PLN" do
      pln = %PLN{
        id_number: "A12345",
        type_of_id_number: "MD",
        state_other_qualifying_information: "CA",
        expiration_date: ~D[2028-12-31]
      }

      assert PLN.encode(pln) == ["A12345", "MD", "CA", "20281231"]
    end

    test "encodes PLN without expiration" do
      pln = %PLN{id_number: "DEA98765", type_of_id_number: "DEA"}
      assert PLN.encode(pln) == ["DEA98765", "DEA"]
    end

    test "encodes PLN with partial date" do
      pln = %PLN{
        id_number: "NP111",
        type_of_id_number: "NP",
        state_other_qualifying_information: "NY",
        expiration_date: %DT{year: 2028, month: 12}
      }

      assert PLN.encode(pln) == ["NP111", "NP", "NY", "202812"]
    end

    test "encodes nil" do
      assert PLN.encode(nil) == []
    end

    test "encodes empty struct" do
      assert PLN.encode(%PLN{}) == []
    end
  end

  describe "round-trip" do
    test "full PLN round-trips" do
      components = ["A12345", "MD", "CA", "20281231"]
      assert components |> PLN.parse() |> PLN.encode() == components
    end

    test "PLN without expiration round-trips" do
      components = ["DEA98765", "DEA"]
      assert components |> PLN.parse() |> PLN.encode() == components
    end

    test "PLN with partial date round-trips" do
      components = ["NP111", "NP", "NY", "202812"]
      assert components |> PLN.parse() |> PLN.encode() == components
    end
  end
end
