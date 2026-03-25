defmodule HL7v2.Type.PTATest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.{PTA, NM}

  doctest PTA

  describe "parse/1" do
    test "parses all components" do
      result = PTA.parse(["ANC", "LM", "1000"])
      assert result.policy_type == "ANC"
      assert result.amount_class == "LM"
      assert %NM{value: "1000"} = result.money_or_percentage_quantity
    end

    test "parses empty list" do
      assert PTA.parse([]).policy_type == nil
    end
  end

  describe "encode/1" do
    test "encodes PTA" do
      pta = %PTA{
        policy_type: "ANC",
        amount_class: "LM",
        money_or_percentage_quantity: %NM{value: "1000", original: "1000"}
      }

      assert PTA.encode(pta) == ["ANC", "LM", "1000"]
    end

    test "encodes nil" do
      assert PTA.encode(nil) == []
    end
  end

  describe "round-trip" do
    test "round-trips" do
      components = ["ANC", "LM", "1000"]
      assert components |> PTA.parse() |> PTA.encode() == components
    end
  end
end
