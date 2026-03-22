defmodule HL7v2.Type.TXTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.TX

  doctest TX

  describe "parse/1" do
    test "preserves leading whitespace" do
      assert TX.parse("  indented") == "  indented"
    end

    test "returns nil for empty" do
      assert TX.parse("") == nil
    end

    test "returns nil for nil" do
      assert TX.parse(nil) == nil
    end
  end

  describe "encode/1" do
    test "returns value as-is" do
      assert TX.encode("  indented") == "  indented"
    end

    test "returns empty for nil" do
      assert TX.encode(nil) == ""
    end
  end

  describe "round-trip" do
    test "preserves leading spaces" do
      assert "  indented text" |> TX.parse() |> TX.encode() == "  indented text"
    end
  end
end
