defmodule HL7v2.Type.WVITest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.WVI

  doctest WVI

  describe "parse/1" do
    test "parses channel number and name" do
      result = WVI.parse(["1", "Lead I"])
      assert result.channel_number == "1"
      assert result.channel_name == "Lead I"
    end

    test "parses number only" do
      result = WVI.parse(["3"])
      assert result.channel_number == "3"
      assert result.channel_name == nil
    end

    test "parses empty list" do
      assert WVI.parse([]).channel_number == nil
    end
  end

  describe "encode/1" do
    test "encodes WVI" do
      wvi = %WVI{channel_number: "1", channel_name: "Lead I"}
      assert WVI.encode(wvi) == ["1", "Lead I"]
    end

    test "encodes nil" do
      assert WVI.encode(nil) == []
    end
  end

  describe "round-trip" do
    test "round-trips" do
      components = ["1", "Lead I"]
      assert components |> WVI.parse() |> WVI.encode() == components
    end
  end
end
