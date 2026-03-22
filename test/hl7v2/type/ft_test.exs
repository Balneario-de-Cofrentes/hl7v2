defmodule HL7v2.Type.FTTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.FT

  doctest FT

  describe "parse/1" do
    test "preserves escape sequences" do
      assert FT.parse("Line 1\\.br\\Line 2") == "Line 1\\.br\\Line 2"
    end

    test "returns nil for empty" do
      assert FT.parse("") == nil
    end

    test "returns nil for nil" do
      assert FT.parse(nil) == nil
    end
  end

  describe "encode/1" do
    test "returns value as-is" do
      assert FT.encode("formatted") == "formatted"
    end

    test "returns empty for nil" do
      assert FT.encode(nil) == ""
    end
  end

  describe "round-trip" do
    test "value round-trips" do
      text = "Report: \\H\\BOLD\\N\\ normal"
      assert text |> FT.parse() |> FT.encode() == text
    end
  end
end
