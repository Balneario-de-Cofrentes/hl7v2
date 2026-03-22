defmodule HL7v2.Type.IDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.ID

  doctest ID

  describe "parse/1" do
    test "returns value as-is" do
      assert ID.parse("MR") == "MR"
    end

    test "returns nil for empty" do
      assert ID.parse("") == nil
    end

    test "returns nil for nil" do
      assert ID.parse(nil) == nil
    end
  end

  describe "encode/1" do
    test "returns value as-is" do
      assert ID.encode("MR") == "MR"
    end

    test "returns empty for nil" do
      assert ID.encode(nil) == ""
    end
  end

  describe "round-trip" do
    test "value round-trips" do
      assert "MR" |> ID.parse() |> ID.encode() == "MR"
    end
  end
end
