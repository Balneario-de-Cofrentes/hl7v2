defmodule HL7v2.Type.NRTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.NR

  doctest NR

  describe "parse/1" do
    test "parses full range" do
      result = NR.parse(["2.5", "10.0"])
      assert result.low == "2.5"
      assert result.high == "10"
    end

    test "parses open-ended high" do
      result = NR.parse(["5", ""])
      assert result.low == "5"
      assert result.high == nil
    end

    test "parses open-ended low" do
      result = NR.parse(["", "100"])
      assert result.low == nil
      assert result.high == "100"
    end

    test "parses empty list" do
      result = NR.parse([])
      assert result.low == nil
      assert result.high == nil
    end
  end

  describe "encode/1" do
    test "encodes full range" do
      assert NR.encode(%NR{low: "2.5", high: "10"}) == ["2.5", "10"]
    end

    test "encodes open-ended high" do
      assert NR.encode(%NR{low: "5"}) == ["5"]
    end

    test "encodes nil" do
      assert NR.encode(nil) == []
    end

    test "encodes empty struct" do
      assert NR.encode(%NR{}) == []
    end
  end

  describe "round-trip" do
    test "full range round-trips" do
      components = ["2.5", "10"]
      assert components |> NR.parse() |> NR.encode() == components
    end
  end
end
