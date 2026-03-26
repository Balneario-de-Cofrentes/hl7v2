defmodule HL7v2.Type.SITest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias HL7v2.Type.SI

  doctest SI

  describe "parse/1" do
    test "parses valid sequence IDs" do
      assert SI.parse("0") == 0
      assert SI.parse("1") == 1
      assert SI.parse("9999") == 9999
    end

    test "preserves out-of-range values as raw string" do
      assert SI.parse("-1") == "-1"
      assert SI.parse("10000") == "10000"
    end

    test "preserves non-numeric input as raw string" do
      assert SI.parse("abc") == "abc"
    end

    test "returns nil for empty" do
      assert SI.parse("") == nil
    end

    test "returns nil for nil" do
      assert SI.parse(nil) == nil
    end

    test "strips whitespace" do
      assert SI.parse("  42  ") == 42
    end
  end

  describe "encode/1" do
    test "encodes integer to string" do
      assert SI.encode(1) == "1"
      assert SI.encode(0) == "0"
      assert SI.encode(9999) == "9999"
    end

    test "returns empty for nil" do
      assert SI.encode(nil) == ""
    end
  end

  describe "round-trip" do
    test "parse then encode" do
      assert "42" |> SI.parse() |> SI.encode() == "42"
    end
  end

  property "valid range round-trip" do
    check all(n <- integer(0..9999)) do
      str = Integer.to_string(n)
      assert str |> SI.parse() |> SI.encode() == str
    end
  end
end
