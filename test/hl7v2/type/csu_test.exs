defmodule HL7v2.Type.CSUTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.CSU

  doctest CSU

  describe "parse/1" do
    test "parses sensitivity and units" do
      result = CSU.parse(["0.1", "mV", "millivolts", "UCUM"])
      assert result.channel_sensitivity == "0.1"
      assert result.unit_of_measure_identifier == "mV"
      assert result.unit_of_measure_description == "millivolts"
      assert result.unit_of_measure_coding_system == "UCUM"
    end

    test "parses empty list" do
      assert CSU.parse([]).channel_sensitivity == nil
    end
  end

  describe "encode/1" do
    test "encodes CSU" do
      csu = %CSU{channel_sensitivity: "0.1", unit_of_measure_identifier: "mV"}
      assert CSU.encode(csu) == ["0.1", "mV"]
    end

    test "encodes nil" do
      assert CSU.encode(nil) == []
    end
  end

  describe "round-trip" do
    test "full CSU round-trips" do
      components = ["0.1", "mV", "millivolts", "UCUM"]
      assert components |> CSU.parse() |> CSU.encode() == components
    end
  end
end
