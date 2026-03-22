defmodule HL7v2.Type.NRTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.NM
  alias HL7v2.Type.NR

  doctest NR

  describe "parse/1" do
    test "parses full range" do
      result = NR.parse(["2.5", "10.0"])
      assert %NM{value: "2.5", original: "2.5"} = result.low
      assert %NM{value: "10", original: "10.0"} = result.high
    end

    test "parses open-ended high" do
      result = NR.parse(["5", ""])
      assert %NM{value: "5"} = result.low
      assert result.high == nil
    end

    test "parses open-ended low" do
      result = NR.parse(["", "100"])
      assert result.low == nil
      assert %NM{value: "100"} = result.high
    end

    test "parses empty list" do
      result = NR.parse([])
      assert result.low == nil
      assert result.high == nil
    end
  end

  describe "encode/1" do
    test "encodes full range with NM structs" do
      nr = %NR{
        low: %NM{value: "2.5", original: "2.5"},
        high: %NM{value: "10", original: "10"}
      }

      assert NR.encode(nr) == ["2.5", "10"]
    end

    test "encodes full range with plain strings (backward compat)" do
      assert NR.encode(%NR{low: "2.5", high: "10"}) == ["2.5", "10"]
    end

    test "encodes open-ended high" do
      assert NR.encode(%NR{low: %NM{value: "5", original: "5"}}) == ["5"]
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

    test "round-trip preserves original wire format" do
      components = ["02.50", "10.0"]
      assert components |> NR.parse() |> NR.encode() == components
    end
  end
end
