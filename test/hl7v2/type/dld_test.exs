defmodule HL7v2.Type.DLDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.DLD
  alias HL7v2.Type.{TS, DTM}

  doctest DLD

  describe "parse/1" do
    test "parses location only" do
      result = DLD.parse(["HOME"])
      assert result.discharge_to_location == "HOME"
      assert result.effective_date == nil
    end

    test "parses location with effective date" do
      result = DLD.parse(["HOME", "20260322"])
      assert result.discharge_to_location == "HOME"
      assert %TS{time: %DTM{year: 2026, month: 3, day: 22}} = result.effective_date
    end

    test "parses with sub-component date (degree of precision)" do
      result = DLD.parse(["SNF", "20260322&D"])
      assert result.discharge_to_location == "SNF"

      assert %TS{time: %DTM{year: 2026, month: 3, day: 22}, degree_of_precision: "D"} =
               result.effective_date
    end

    test "parses empty list" do
      result = DLD.parse([])
      assert result.discharge_to_location == nil
      assert result.effective_date == nil
    end
  end

  describe "encode/1" do
    test "encodes location only" do
      assert DLD.encode(%DLD{discharge_to_location: "HOME"}) == ["HOME"]
    end

    test "encodes location with effective date" do
      dld = %DLD{
        discharge_to_location: "HOME",
        effective_date: %TS{time: %DTM{year: 2026, month: 3, day: 22}}
      }

      assert DLD.encode(dld) == ["HOME", "20260322"]
    end

    test "encodes nil" do
      assert DLD.encode(nil) == []
    end

    test "encodes empty struct" do
      assert DLD.encode(%DLD{}) == []
    end
  end

  describe "round-trip" do
    test "location-only round-trips" do
      components = ["HOME"]
      assert components |> DLD.parse() |> DLD.encode() == components
    end

    test "full DLD round-trips" do
      components = ["HOME", "20260322"]
      assert components |> DLD.parse() |> DLD.encode() == components
    end
  end
end
