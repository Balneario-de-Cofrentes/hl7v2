defmodule HL7v2.Type.MATest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.MA

  doctest MA

  describe "parse/1" do
    test "parses multiple values" do
      result = MA.parse(["1.2", "3.4", "5.6"])
      assert result.values == ["1.2", "3.4", "5.6"]
    end

    test "parses single value" do
      result = MA.parse(["100"])
      assert result.values == ["100"]
    end

    test "parses empty list" do
      result = MA.parse([])
      assert result.values == []
    end
  end

  describe "encode/1" do
    test "encodes values" do
      assert MA.encode(%MA{values: ["1.2", "3.4"]}) == ["1.2", "3.4"]
    end

    test "encodes nil" do
      assert MA.encode(nil) == []
    end

    test "encodes empty" do
      assert MA.encode(%MA{}) == []
    end
  end

  describe "round-trip" do
    test "round-trips" do
      components = ["1.2", "3.4", "5.6"]
      assert components |> MA.parse() |> MA.encode() == components
    end
  end
end
