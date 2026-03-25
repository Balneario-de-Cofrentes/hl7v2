defmodule HL7v2.Type.GTSTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.GTS

  doctest GTS

  describe "parse/1" do
    test "parses timing specification" do
      assert GTS.parse("200602011430-0500") == "200602011430-0500"
    end

    test "parses empty string" do
      assert GTS.parse("") == nil
    end

    test "parses nil" do
      assert GTS.parse(nil) == nil
    end
  end

  describe "encode/1" do
    test "encodes value" do
      assert GTS.encode("200602011430-0500") == "200602011430-0500"
    end

    test "encodes nil" do
      assert GTS.encode(nil) == ""
    end
  end

  describe "round-trip" do
    test "round-trips" do
      value = "200602011430-0500"
      assert value |> GTS.parse() |> GTS.encode() == value
    end
  end
end
