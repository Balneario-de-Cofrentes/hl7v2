defmodule HL7v2.Type.SNTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.SN
  alias HL7v2.Type.NM

  doctest SN

  describe "parse/1" do
    test "parses comparator with single value" do
      result = SN.parse([">", "100"])
      assert result.comparator == ">"
      assert %NM{value: "100"} = result.num1
      assert result.separator_suffix == nil
      assert result.num2 == nil
    end

    test "parses range with separator" do
      result = SN.parse(["", "100", "-", "200"])
      assert result.comparator == nil
      assert %NM{value: "100"} = result.num1
      assert result.separator_suffix == "-"
      assert %NM{value: "200"} = result.num2
    end

    test "parses titer ratio" do
      result = SN.parse(["", "1", ":", "256"])
      assert %NM{value: "1"} = result.num1
      assert result.separator_suffix == ":"
      assert %NM{value: "256"} = result.num2
    end

    test "parses greater-than-or-equal" do
      result = SN.parse([">=", "5.0"])
      assert result.comparator == ">="
      assert %NM{value: "5"} = result.num1
    end

    test "parses less-than" do
      result = SN.parse(["<", "10"])
      assert result.comparator == "<"
      assert %NM{value: "10"} = result.num1
    end

    test "parses ratio with slash" do
      result = SN.parse(["", "3", "/", "4"])
      assert %NM{value: "3"} = result.num1
      assert result.separator_suffix == "/"
      assert %NM{value: "4"} = result.num2
    end

    test "parses empty list" do
      result = SN.parse([])
      assert result.comparator == nil
      assert result.num1 == nil
      assert result.separator_suffix == nil
      assert result.num2 == nil
    end
  end

  describe "encode/1" do
    test "encodes comparator with value" do
      sn = %SN{comparator: ">", num1: %NM{value: "100", original: "100"}}
      assert SN.encode(sn) == [">", "100"]
    end

    test "encodes range" do
      sn = %SN{
        num1: %NM{value: "100", original: "100"},
        separator_suffix: "-",
        num2: %NM{value: "200", original: "200"}
      }

      assert SN.encode(sn) == ["", "100", "-", "200"]
    end

    test "encodes titer" do
      sn = %SN{
        num1: %NM{value: "1", original: "1"},
        separator_suffix: ":",
        num2: %NM{value: "256", original: "256"}
      }

      assert SN.encode(sn) == ["", "1", ":", "256"]
    end

    test "encodes nil" do
      assert SN.encode(nil) == []
    end

    test "encodes empty struct" do
      assert SN.encode(%SN{}) == []
    end
  end

  describe "round-trip" do
    test "comparator round-trips" do
      components = [">", "100"]
      assert components |> SN.parse() |> SN.encode() == components
    end

    test "range round-trips" do
      components = ["", "100", "-", "200"]
      assert components |> SN.parse() |> SN.encode() == components
    end

    test "titer round-trips" do
      components = ["", "1", ":", "256"]
      assert components |> SN.parse() |> SN.encode() == components
    end

    test "preserves original wire format" do
      components = [">=", "+05.0"]
      assert components |> SN.parse() |> SN.encode() == components
    end
  end
end
