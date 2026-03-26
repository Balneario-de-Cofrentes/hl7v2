defmodule HL7v2.Type.CCPTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.CCP

  doctest CCP

  describe "parse/1" do
    test "parses all three components" do
      result = CCP.parse(["1.5", "0.0", "0.003"])
      assert result.channel_calibration_sensitivity_correction_factor == "1.5"
      assert result.channel_calibration_baseline == "0.0"
      assert result.channel_calibration_time_skew == "0.003"
    end

    test "parses sensitivity factor only" do
      result = CCP.parse(["1.2"])
      assert result.channel_calibration_sensitivity_correction_factor == "1.2"
      assert result.channel_calibration_baseline == nil
      assert result.channel_calibration_time_skew == nil
    end

    test "parses two components" do
      result = CCP.parse(["0.95", "10"])
      assert result.channel_calibration_sensitivity_correction_factor == "0.95"
      assert result.channel_calibration_baseline == "10"
      assert result.channel_calibration_time_skew == nil
    end

    test "parses empty list" do
      result = CCP.parse([])
      assert result.channel_calibration_sensitivity_correction_factor == nil
      assert result.channel_calibration_baseline == nil
      assert result.channel_calibration_time_skew == nil
    end
  end

  describe "encode/1" do
    test "encodes all components" do
      ccp = %CCP{
        channel_calibration_sensitivity_correction_factor: "1.5",
        channel_calibration_baseline: "0.0",
        channel_calibration_time_skew: "0.003"
      }

      assert CCP.encode(ccp) == ["1.5", "0.0", "0.003"]
    end

    test "trims trailing empty components" do
      ccp = %CCP{channel_calibration_sensitivity_correction_factor: "1.2"}
      assert CCP.encode(ccp) == ["1.2"]
    end

    test "encodes nil" do
      assert CCP.encode(nil) == []
    end
  end

  describe "round-trip" do
    test "round-trips all components" do
      components = ["1.5", "0.0", "0.003"]
      assert components |> CCP.parse() |> CCP.encode() == components
    end

    test "round-trips single component" do
      components = ["2.0"]
      assert components |> CCP.parse() |> CCP.encode() == components
    end
  end
end
