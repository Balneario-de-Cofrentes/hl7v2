defmodule HL7v2.Type.NMTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias HL7v2.Type.NM

  doctest NM

  describe "parse/1" do
    test "parses positive integer" do
      assert %NM{value: "123", original: "123"} = NM.parse("123")
    end

    test "parses negative integer" do
      assert %NM{value: "-45", original: "-45"} = NM.parse("-45")
    end

    test "parses decimal" do
      assert %NM{value: "3.14", original: "3.14"} = NM.parse("3.14")
    end

    test "parses negative decimal" do
      assert %NM{value: "-45.67", original: "-45.67"} = NM.parse("-45.67")
    end

    test "normalizes leading plus sign in value but preserves original" do
      nm = NM.parse("+123")
      assert nm.value == "123"
      assert nm.original == "+123"
    end

    test "normalizes leading zeros in value but preserves original" do
      nm = NM.parse("01")
      assert nm.value == "1"
      assert nm.original == "01"

      nm = NM.parse("007")
      assert nm.value == "7"
      assert nm.original == "007"
    end

    test "normalizes trailing decimal zeros in value but preserves original" do
      nm = NM.parse("1.20")
      assert nm.value == "1.2"
      assert nm.original == "1.20"

      nm = NM.parse("1.00")
      assert nm.value == "1"
      assert nm.original == "1.00"
    end

    test "normalizes combined leading/trailing zeros in value but preserves original" do
      nm = NM.parse("+01.20")
      assert nm.value == "1.2"
      assert nm.original == "+01.20"
    end

    test "parses zero" do
      assert %NM{value: "0", original: "0"} = NM.parse("0")
    end

    test "normalizes negative zero to zero in value" do
      nm = NM.parse("-0")
      assert nm.value == "0"
      assert nm.original == "-0"

      nm = NM.parse("-0.0")
      assert nm.value == "0"
      assert nm.original == "-0.0"
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

    test "preserves raw input with whitespace in original" do
      nm = NM.parse("  123  ")
      assert nm.value == "123"
      assert nm.original == "  123  "
    end
  end

  describe "encode/1" do
    test "encodes NM struct with original" do
      assert NM.encode(%NM{value: "1.2", original: "+01.20"}) == "+01.20"
    end

    test "encodes NM struct without original falls back to value" do
      assert NM.encode(%NM{value: "42"}) == "42"
    end

    test "encodes string value (backward compat)" do
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
    test "parse then encode preserves original wire format" do
      assert "+01.20" |> NM.parse() |> NM.encode() == "+01.20"
      assert "007" |> NM.parse() |> NM.encode() == "007"
      assert "-0" |> NM.parse() |> NM.encode() == "-0"
      assert "1.00" |> NM.parse() |> NM.encode() == "1.00"
    end

    test "parse then encode preserves already-canonical values" do
      assert "123" |> NM.parse() |> NM.encode() == "123"
      assert "-3.14" |> NM.parse() |> NM.encode() == "-3.14"
    end

    test "programmatic struct without original encodes from value" do
      assert NM.encode(%NM{value: "42"}) == "42"
    end
  end

  property "round-trip for valid integers" do
    check all(n <- integer(-9999..9999)) do
      str = Integer.to_string(n)
      parsed = NM.parse(str)
      assert parsed != nil
      assert NM.encode(parsed) == str
    end
  end
end
