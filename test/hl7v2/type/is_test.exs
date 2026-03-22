defmodule HL7v2.Type.ISTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.IS

  doctest IS

  describe "parse/1" do
    test "returns value as-is" do
      assert IS.parse("ICU") == "ICU"
    end

    test "returns nil for empty" do
      assert IS.parse("") == nil
    end

    test "returns nil for nil" do
      assert IS.parse(nil) == nil
    end
  end

  describe "encode/1" do
    test "returns value as-is" do
      assert IS.encode("ICU") == "ICU"
    end

    test "returns empty for nil" do
      assert IS.encode(nil) == ""
    end
  end

  describe "round-trip" do
    test "value round-trips" do
      assert "ICU" |> IS.parse() |> IS.encode() == "ICU"
    end
  end
end
