defmodule HL7v2.Type.FNTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.FN

  doctest FN

  describe "parse/1" do
    test "parses surname only" do
      result = FN.parse(["Smith"])
      assert result.surname == "Smith"
      assert result.own_surname_prefix == nil
    end

    test "parses with prefix" do
      result = FN.parse(["Smith", "Van"])
      assert result.surname == "Smith"
      assert result.own_surname_prefix == "Van"
    end

    test "parses all sub-components" do
      result = FN.parse(["Smith", "Van", "SmithOwn", "De", "Partner"])
      assert result.surname == "Smith"
      assert result.own_surname_prefix == "Van"
      assert result.own_surname == "SmithOwn"
      assert result.surname_prefix_from_partner == "De"
      assert result.surname_from_partner == "Partner"
    end

    test "parses empty list" do
      result = FN.parse([])
      assert result.surname == nil
    end

    test "handles empty sub-components" do
      result = FN.parse(["Smith", "", ""])
      assert result.surname == "Smith"
      assert result.own_surname_prefix == nil
      assert result.own_surname == nil
    end
  end

  describe "encode/1" do
    test "encodes surname only" do
      assert FN.encode(%FN{surname: "Smith"}) == ["Smith"]
    end

    test "encodes with prefix" do
      assert FN.encode(%FN{surname: "Smith", own_surname_prefix: "Van"}) == ["Smith", "Van"]
    end

    test "encodes nil" do
      assert FN.encode(nil) == []
    end

    test "trims trailing empty components" do
      assert FN.encode(%FN{surname: "Smith", own_surname: nil}) == ["Smith"]
    end
  end

  describe "round-trip" do
    test "simple surname round-trips" do
      components = ["Smith"]
      assert components |> FN.parse() |> FN.encode() == components
    end

    test "full name round-trips" do
      components = ["Smith", "Van", "SmithOwn", "De", "Partner"]
      assert components |> FN.parse() |> FN.encode() == components
    end
  end
end
