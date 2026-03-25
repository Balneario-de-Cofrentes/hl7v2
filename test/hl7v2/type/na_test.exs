defmodule HL7v2.Type.NATest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.NA

  doctest NA

  describe "parse/1" do
    test "parses multiple values" do
      result = NA.parse(["10", "20", "30", "40"])
      assert result.values == ["10", "20", "30", "40"]
    end

    test "parses empty list" do
      result = NA.parse([])
      assert result.values == []
    end
  end

  describe "encode/1" do
    test "encodes values" do
      assert NA.encode(%NA{values: ["10", "20"]}) == ["10", "20"]
    end

    test "encodes nil" do
      assert NA.encode(nil) == []
    end
  end

  describe "round-trip" do
    test "round-trips" do
      components = ["10", "20", "30", "40"]
      assert components |> NA.parse() |> NA.encode() == components
    end
  end
end
