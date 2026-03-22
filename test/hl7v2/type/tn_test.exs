defmodule HL7v2.Type.TNTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.TN

  doctest TN

  describe "parse/1" do
    test "parses phone number" do
      assert TN.parse("(555)555-1234X5678") == "(555)555-1234X5678"
    end

    test "returns nil for empty" do
      assert TN.parse("") == nil
    end

    test "returns nil for nil" do
      assert TN.parse(nil) == nil
    end
  end

  describe "encode/1" do
    test "returns value as-is" do
      assert TN.encode("(555)555-1234") == "(555)555-1234"
    end

    test "returns empty for nil" do
      assert TN.encode(nil) == ""
    end
  end

  describe "round-trip" do
    test "value round-trips" do
      assert "(555)555-1234" |> TN.parse() |> TN.encode() == "(555)555-1234"
    end
  end
end
