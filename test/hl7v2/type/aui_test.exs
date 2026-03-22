defmodule HL7v2.Type.AUITest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.AUI

  doctest AUI

  describe "parse/1" do
    test "parses all three components" do
      result = AUI.parse(["AUTH123", "20260315", "BCBS"])
      assert result.authorization_number == "AUTH123"
      assert result.date == ~D[2026-03-15]
      assert result.source == "BCBS"
    end

    test "parses authorization number only" do
      result = AUI.parse(["AUTH123"])
      assert result.authorization_number == "AUTH123"
      assert result.date == nil
      assert result.source == nil
    end

    test "parses authorization with date" do
      result = AUI.parse(["AUTH123", "20260315"])
      assert result.authorization_number == "AUTH123"
      assert result.date == ~D[2026-03-15]
      assert result.source == nil
    end

    test "parses partial date" do
      result = AUI.parse(["AUTH123", "202603"])
      assert result.authorization_number == "AUTH123"
      assert result.date == %HL7v2.Type.DT{year: 2026, month: 3}
    end

    test "parses empty list" do
      result = AUI.parse([])
      assert result.authorization_number == nil
      assert result.date == nil
      assert result.source == nil
    end
  end

  describe "encode/1" do
    test "encodes all components" do
      aui = %AUI{
        authorization_number: "AUTH123",
        date: ~D[2026-03-15],
        source: "BCBS"
      }

      assert AUI.encode(aui) == ["AUTH123", "20260315", "BCBS"]
    end

    test "encodes authorization number only" do
      assert AUI.encode(%AUI{authorization_number: "AUTH123"}) == ["AUTH123"]
    end

    test "encodes nil" do
      assert AUI.encode(nil) == []
    end

    test "encodes empty struct" do
      assert AUI.encode(%AUI{}) == []
    end
  end

  describe "round-trip" do
    test "full AUI round-trips" do
      components = ["AUTH123", "20260315", "BCBS"]
      assert components |> AUI.parse() |> AUI.encode() == components
    end

    test "authorization-only round-trips" do
      components = ["AUTH123"]
      assert components |> AUI.parse() |> AUI.encode() == components
    end

    test "authorization with date round-trips" do
      components = ["AUTH123", "20260315"]
      assert components |> AUI.parse() |> AUI.encode() == components
    end
  end
end
