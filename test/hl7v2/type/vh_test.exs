defmodule HL7v2.Type.VHTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.VH

  doctest VH

  describe "parse/1" do
    test "parses visiting hours" do
      result = VH.parse(["MON", "FRI", "0800", "1700"])
      assert result.start_day_range == "MON"
      assert result.end_day_range == "FRI"
      assert result.start_hour_range == "0800"
      assert result.end_hour_range == "1700"
    end

    test "parses day range only" do
      result = VH.parse(["SAT", "SUN"])
      assert result.start_day_range == "SAT"
      assert result.end_day_range == "SUN"
      assert result.start_hour_range == nil
    end

    test "parses empty list" do
      assert VH.parse([]).start_day_range == nil
    end
  end

  describe "encode/1" do
    test "encodes VH" do
      vh = %VH{
        start_day_range: "MON",
        end_day_range: "FRI",
        start_hour_range: "0800",
        end_hour_range: "1700"
      }

      assert VH.encode(vh) == ["MON", "FRI", "0800", "1700"]
    end

    test "encodes nil" do
      assert VH.encode(nil) == []
    end
  end

  describe "round-trip" do
    test "round-trips" do
      components = ["MON", "FRI", "0800", "1700"]
      assert components |> VH.parse() |> VH.encode() == components
    end
  end
end
