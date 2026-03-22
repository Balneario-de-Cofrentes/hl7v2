defmodule HL7v2.Type.MOCTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.MOC
  alias HL7v2.Type.{MO, CE}

  doctest MOC

  describe "parse/1" do
    test "parses both monetary amount and charge code" do
      result = MOC.parse(["150.00&USD", "99213&Office Visit&CPT4"])

      assert %MO{quantity: "150.00", denomination: "USD"} = result.monetary_amount

      assert %CE{identifier: "99213", text: "Office Visit", name_of_coding_system: "CPT4"} =
               result.charge_code
    end

    test "parses monetary amount only" do
      result = MOC.parse(["150.00&USD"])
      assert %MO{quantity: "150.00", denomination: "USD"} = result.monetary_amount
      assert result.charge_code == nil
    end

    test "parses quantity without denomination" do
      result = MOC.parse(["250"])
      assert %MO{quantity: "250"} = result.monetary_amount
      assert result.charge_code == nil
    end

    test "parses empty list" do
      result = MOC.parse([])
      assert result.monetary_amount == nil
      assert result.charge_code == nil
    end
  end

  describe "encode/1" do
    test "encodes both components" do
      moc = %MOC{
        monetary_amount: %MO{quantity: "150.00", denomination: "USD"},
        charge_code: %CE{identifier: "99213", text: "Office Visit", name_of_coding_system: "CPT4"}
      }

      assert MOC.encode(moc) == ["150.00&USD", "99213&Office Visit&CPT4"]
    end

    test "encodes monetary amount only" do
      moc = %MOC{monetary_amount: %MO{quantity: "150.00", denomination: "USD"}}
      assert MOC.encode(moc) == ["150.00&USD"]
    end

    test "encodes nil" do
      assert MOC.encode(nil) == []
    end

    test "encodes empty struct" do
      assert MOC.encode(%MOC{}) == []
    end
  end

  describe "round-trip" do
    test "full MOC round-trips" do
      components = ["150.00&USD", "99213&Office Visit&CPT4"]
      assert components |> MOC.parse() |> MOC.encode() == components
    end

    test "monetary-only round-trips" do
      components = ["150.00&USD"]
      assert components |> MOC.parse() |> MOC.encode() == components
    end
  end
end
