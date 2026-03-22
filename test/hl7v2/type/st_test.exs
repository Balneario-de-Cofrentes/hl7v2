defmodule HL7v2.Type.STTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.ST

  doctest ST

  describe "parse/1" do
    test "returns the string as-is" do
      assert ST.parse("Hello World") == "Hello World"
    end

    test "returns nil for empty string" do
      assert ST.parse("") == nil
    end

    test "returns nil for nil" do
      assert ST.parse(nil) == nil
    end

    test "preserves special characters" do
      assert ST.parse("test with spaces") == "test with spaces"
    end

    test "preserves unicode" do
      assert ST.parse("Garcia") == "Garcia"
    end
  end

  describe "encode/1" do
    test "returns the string as-is" do
      assert ST.encode("Hello") == "Hello"
    end

    test "returns empty string for nil" do
      assert ST.encode(nil) == ""
    end
  end

  describe "round-trip" do
    test "parse then encode preserves value" do
      value = "Test String 123"
      assert value |> ST.parse() |> ST.encode() == value
    end

    test "nil round-trips through empty string" do
      assert nil |> ST.encode() |> ST.parse() == nil
    end
  end
end
