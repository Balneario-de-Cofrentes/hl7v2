defmodule HL7v2.Type.PTTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.PT

  doctest PT

  describe "parse/1" do
    test "parses processing ID only" do
      result = PT.parse(["P"])
      assert result.processing_id == "P"
      assert result.processing_mode == nil
    end

    test "parses both fields" do
      result = PT.parse(["P", "T"])
      assert result.processing_id == "P"
      assert result.processing_mode == "T"
    end

    test "parses empty list" do
      result = PT.parse([])
      assert %PT{} = result
      assert result.processing_id == nil
      assert result.processing_mode == nil
    end

    test "parses debug mode" do
      result = PT.parse(["D"])
      assert result.processing_id == "D"
    end

    test "parses training mode" do
      result = PT.parse(["T", "A"])
      assert result.processing_id == "T"
      assert result.processing_mode == "A"
    end
  end

  describe "encode/1" do
    test "encodes nil returns empty list" do
      assert PT.encode(nil) == []
    end

    test "encodes empty struct" do
      assert PT.encode(%PT{}) == []
    end

    test "encodes processing ID only" do
      assert PT.encode(%PT{processing_id: "P"}) == ["P"]
    end

    test "encodes both fields" do
      assert PT.encode(%PT{processing_id: "P", processing_mode: "T"}) == ["P", "T"]
    end

    test "encode round-trip" do
      original = %PT{processing_id: "D", processing_mode: "R"}
      parsed = original |> PT.encode() |> PT.parse()
      assert parsed.processing_id == "D"
      assert parsed.processing_mode == "R"
    end
  end
end
