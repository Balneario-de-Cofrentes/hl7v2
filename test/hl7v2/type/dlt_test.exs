defmodule HL7v2.Type.DLTTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.{DLT, NR, NM}

  doctest DLT

  describe "parse/1" do
    test "parses all components" do
      result = DLT.parse(["2.5&10.0", "5", "P", "7"])
      assert %NR{low: %NM{value: "2.5"}, high: %NM{value: "10"}} = result.normal_range
      assert result.numeric_threshold == "5"
      assert result.change_computation == "P"
      assert result.days_retained == "7"
    end

    test "parses empty list" do
      result = DLT.parse([])
      assert result.normal_range == nil
    end
  end

  describe "encode/1" do
    test "encodes nil" do
      assert DLT.encode(nil) == []
    end
  end
end
