defmodule HL7v2.Type.RFRTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.{RFR, NR, NM}

  doctest RFR

  describe "parse/1" do
    test "parses numeric range and sex" do
      result = RFR.parse(["3.5&5.5", "M"])
      assert %NR{low: %NM{value: "3.5"}, high: %NM{value: "5.5"}} = result.numeric_range
      assert result.administrative_sex == "M"
    end

    test "parses with conditions" do
      result = RFR.parse(["0&100", "", "", "", "", "", "Fasting"])
      assert result.conditions == "Fasting"
    end

    test "parses empty list" do
      assert RFR.parse([]).numeric_range == nil
    end
  end

  describe "encode/1" do
    test "encodes RFR" do
      rfr = %RFR{
        numeric_range: %NR{
          low: %NM{value: "3.5", original: "3.5"},
          high: %NM{value: "5.5", original: "5.5"}
        },
        administrative_sex: "M"
      }

      assert RFR.encode(rfr) == ["3.5&5.5", "M"]
    end

    test "encodes nil" do
      assert RFR.encode(nil) == []
    end
  end
end
