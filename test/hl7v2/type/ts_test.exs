defmodule HL7v2.Type.TSTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.{TS, DTM}

  doctest TS

  describe "parse/1" do
    test "parses time component" do
      result = TS.parse(["20260322143022"])

      assert result == %TS{
               time: %DTM{year: 2026, month: 3, day: 22, hour: 14, minute: 30, second: 22}
             }
    end

    test "parses with degree of precision" do
      result = TS.parse(["20260322", "D"])
      assert result.time == %DTM{year: 2026, month: 3, day: 22}
      assert result.degree_of_precision == "D"
    end

    test "parses empty list" do
      result = TS.parse([])
      assert result.time == nil
      assert result.degree_of_precision == nil
    end

    test "parses single empty component" do
      result = TS.parse([""])
      assert result.time == nil
    end
  end

  describe "encode/1" do
    test "encodes time only" do
      ts = %TS{time: %DTM{year: 2026, month: 3, day: 22}}
      assert TS.encode(ts) == ["20260322"]
    end

    test "encodes with degree of precision" do
      ts = %TS{time: %DTM{year: 2026, month: 3, day: 22}, degree_of_precision: "D"}
      assert TS.encode(ts) == ["20260322", "D"]
    end

    test "encodes nil" do
      assert TS.encode(nil) == []
    end

    test "encodes empty struct" do
      assert TS.encode(%TS{}) == []
    end
  end

  describe "round-trip" do
    test "time-only round-trip" do
      components = ["20260322143022"]
      assert components |> TS.parse() |> TS.encode() == components
    end

    test "with precision round-trip" do
      components = ["20260322", "D"]
      assert components |> TS.parse() |> TS.encode() == components
    end
  end
end
