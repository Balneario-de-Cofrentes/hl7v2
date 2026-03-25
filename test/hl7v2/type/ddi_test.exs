defmodule HL7v2.Type.DDITest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.{DDI, MO, NM}

  doctest DDI

  describe "parse/1" do
    test "parses all components" do
      result = DDI.parse(["3", "100.00&USD", "30"])
      assert %NM{value: "3"} = result.delay_days
      assert %MO{quantity: "100.00", denomination: "USD"} = result.monetary_amount
      assert %NM{value: "30"} = result.number_of_days
    end

    test "parses empty list" do
      result = DDI.parse([])
      assert result.delay_days == nil
    end
  end

  describe "encode/1" do
    test "encodes nil" do
      assert DDI.encode(nil) == []
    end
  end
end
