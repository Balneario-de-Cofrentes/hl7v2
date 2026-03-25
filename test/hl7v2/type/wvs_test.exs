defmodule HL7v2.Type.WVSTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.WVS

  doctest WVS

  describe "parse/1" do
    test "parses source names" do
      result = WVS.parse(["RA", "LA"])
      assert result.source_one_name == "RA"
      assert result.source_two_name == "LA"
    end

    test "parses single source" do
      result = WVS.parse(["V1"])
      assert result.source_one_name == "V1"
      assert result.source_two_name == nil
    end

    test "parses empty list" do
      assert WVS.parse([]).source_one_name == nil
    end
  end

  describe "encode/1" do
    test "encodes WVS" do
      wvs = %WVS{source_one_name: "RA", source_two_name: "LA"}
      assert WVS.encode(wvs) == ["RA", "LA"]
    end

    test "encodes nil" do
      assert WVS.encode(nil) == []
    end
  end

  describe "round-trip" do
    test "round-trips" do
      components = ["RA", "LA"]
      assert components |> WVS.parse() |> WVS.encode() == components
    end
  end
end
