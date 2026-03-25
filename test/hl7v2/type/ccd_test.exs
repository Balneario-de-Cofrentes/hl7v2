defmodule HL7v2.Type.CCDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.{CCD, TS, DTM}

  doctest CCD

  describe "parse/1" do
    test "parses invocation event and date_time" do
      result = CCD.parse(["D", "20260101120000"])
      assert result.invocation_event == "D"
      assert %TS{time: %DTM{year: 2026, month: 1, day: 1, hour: 12}} = result.date_time
    end

    test "parses event only" do
      result = CCD.parse(["O"])
      assert result.invocation_event == "O"
      assert result.date_time == nil
    end

    test "parses empty list" do
      result = CCD.parse([])
      assert result.invocation_event == nil
      assert result.date_time == nil
    end
  end

  describe "encode/1" do
    test "encodes event only" do
      assert CCD.encode(%CCD{invocation_event: "D"}) == ["D"]
    end

    test "encodes nil" do
      assert CCD.encode(nil) == []
    end

    test "encodes empty struct" do
      assert CCD.encode(%CCD{}) == []
    end
  end

  describe "round-trip" do
    test "event-only round-trips" do
      components = ["D"]
      assert components |> CCD.parse() |> CCD.encode() == components
    end
  end
end
