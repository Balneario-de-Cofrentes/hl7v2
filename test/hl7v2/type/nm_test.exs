defmodule HL7v2.Type.NMTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias HL7v2.Type.NM

  doctest NM

  describe "parse/1" do
    test "parses positive integer" do
      assert NM.parse("123") == "123"
    end

    test "parses negative integer" do
      assert NM.parse("-45") == "-45"
    end

    test "parses decimal" do
      assert NM.parse("3.14") == "3.14"
    end

    test "parses negative decimal" do
      assert NM.parse("-45.67") == "-45.67"
    end

    test "normalizes leading plus sign" do
      assert NM.parse("+123") == "123"
    end

    test "normalizes leading zeros" do
      assert NM.parse("01") == "1"
      assert NM.parse("007") == "7"
    end

    test "normalizes trailing decimal zeros" do
      assert NM.parse("1.20") == "1.2"
      assert NM.parse("1.00") == "1"
    end

    test "normalizes combined leading/trailing zeros" do
      assert NM.parse("+01.20") == "1.2"
    end

    test "parses zero" do
      assert NM.parse("0") == "0"
    end

    test "normalizes negative zero to zero" do
      assert NM.parse("-0") == "0"
      assert NM.parse("-0.0") == "0"
    end

    test "returns nil for empty string" do
      assert NM.parse("") == nil
    end

    test "returns nil for nil" do
      assert NM.parse(nil) == nil
    end

    test "returns nil for invalid input" do
      assert NM.parse("abc") == nil
      assert NM.parse("12.34.56") == nil
      assert NM.parse("12abc") == nil
    end

    test "returns nil for bare decimal point" do
      assert NM.parse(".1") == nil
    end

    test "strips whitespace" do
      assert NM.parse("  123  ") == "123"
    end
  end

  describe "encode/1" do
    test "encodes string value" do
      assert NM.encode("123") == "123"
    end

    test "encodes integer" do
      assert NM.encode(42) == "42"
    end

    test "encodes float" do
      assert NM.encode(3.14) == "3.14"
    end

    test "returns empty string for nil" do
      assert NM.encode(nil) == ""
    end
  end

  describe "round-trip" do
    test "parse then encode preserves normalized value" do
      assert "123" |> NM.parse() |> NM.encode() == "123"
      assert "-3.14" |> NM.parse() |> NM.encode() == "-3.14"
    end
  end

  property "round-trip for valid integers" do
    check all(n <- integer(-9999..9999)) do
      str = Integer.to_string(n)
      parsed = NM.parse(str)
      assert parsed != nil
      assert NM.encode(parsed) == parsed
    end
  end
end
