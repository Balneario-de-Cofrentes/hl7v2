defmodule HL7v2.Type.DTNTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.{DTN, NM}

  doctest DTN

  describe "parse/1" do
    test "parses day type and number" do
      result = DTN.parse(["AP", "10"])
      assert result.day_type == "AP"
      assert %NM{value: "10"} = result.number_of_days
    end

    test "parses empty list" do
      result = DTN.parse([])
      assert result.day_type == nil
    end
  end

  describe "encode/1" do
    test "encodes full DTN" do
      dtn = %DTN{day_type: "AP", number_of_days: %NM{value: "10", original: "10"}}
      assert DTN.encode(dtn) == ["AP", "10"]
    end

    test "encodes nil" do
      assert DTN.encode(nil) == []
    end
  end
end
