defmodule HL7v2.Type.RMCTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.{RMC, NM}

  doctest RMC

  describe "parse/1" do
    test "parses room coverage" do
      result = RMC.parse(["PR", "LM", "500"])
      assert result.room_type == "PR"
      assert result.amount_type == "LM"
      assert %NM{value: "500"} = result.coverage_amount
    end

    test "parses empty list" do
      assert RMC.parse([]).room_type == nil
    end
  end

  describe "encode/1" do
    test "encodes RMC" do
      rmc = %RMC{
        room_type: "PR",
        amount_type: "LM",
        coverage_amount: %NM{value: "500", original: "500"}
      }

      assert RMC.encode(rmc) == ["PR", "LM", "500"]
    end

    test "encodes nil" do
      assert RMC.encode(nil) == []
    end
  end

  describe "round-trip" do
    test "round-trips" do
      components = ["PR", "LM", "500"]
      assert components |> RMC.parse() |> RMC.encode() == components
    end
  end
end
