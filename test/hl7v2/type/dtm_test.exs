defmodule HL7v2.Type.DTMTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.DTM

  doctest DTM

  describe "parse/1" do
    test "parses year-only" do
      assert DTM.parse("2026") == %DTM{year: 2026}
    end

    test "parses year-month" do
      assert DTM.parse("202603") == %DTM{year: 2026, month: 3}
    end

    test "parses year-month-day" do
      assert DTM.parse("20260322") == %DTM{year: 2026, month: 3, day: 22}
    end

    test "parses with hour" do
      assert DTM.parse("2026032214") == %DTM{year: 2026, month: 3, day: 22, hour: 14}
    end

    test "parses with hour and minute" do
      assert DTM.parse("202603221430") == %DTM{
               year: 2026,
               month: 3,
               day: 22,
               hour: 14,
               minute: 30
             }
    end

    test "parses with seconds" do
      assert DTM.parse("20260322143022") == %DTM{
               year: 2026,
               month: 3,
               day: 22,
               hour: 14,
               minute: 30,
               second: 22
             }
    end

    test "parses with fractional seconds" do
      result = DTM.parse("20260322143022.1234")

      assert result == %DTM{
               year: 2026,
               month: 3,
               day: 22,
               hour: 14,
               minute: 30,
               second: 22,
               fraction: "1234"
             }
    end

    test "parses with single digit fraction" do
      result = DTM.parse("20260322143022.1")

      assert result == %DTM{
               year: 2026,
               month: 3,
               day: 22,
               hour: 14,
               minute: 30,
               second: 22,
               fraction: "1"
             }
    end

    test "parses with timezone offset" do
      result = DTM.parse("20260322143022.1234+0100")

      assert result == %DTM{
               year: 2026,
               month: 3,
               day: 22,
               hour: 14,
               minute: 30,
               second: 22,
               fraction: "1234",
               offset: "+0100"
             }
    end

    test "parses with negative timezone offset" do
      result = DTM.parse("202603221430-0500")

      assert result == %DTM{
               year: 2026,
               month: 3,
               day: 22,
               hour: 14,
               minute: 30,
               offset: "-0500"
             }
    end

    test "parses UTC timezone" do
      result = DTM.parse("20260322143022+0000")

      assert result == %DTM{
               year: 2026,
               month: 3,
               day: 22,
               hour: 14,
               minute: 30,
               second: 22,
               offset: "+0000"
             }
    end

    test "parses day precision with timezone" do
      result = DTM.parse("20260322+0100")

      assert result == %DTM{
               year: 2026,
               month: 3,
               day: 22,
               offset: "+0100"
             }
    end

    test "returns nil for empty string" do
      assert DTM.parse("") == nil
    end

    test "returns nil for nil" do
      assert DTM.parse(nil) == nil
    end

    test "returns nil for too-short input" do
      assert DTM.parse("202") == nil
    end

    test "returns nil for invalid month" do
      assert DTM.parse("202613") == nil
    end

    test "returns nil for invalid day" do
      assert DTM.parse("20260332") == nil
    end

    test "returns nil for invalid hour" do
      assert DTM.parse("2026032225") == nil
    end

    test "returns nil for invalid minute" do
      assert DTM.parse("202603221461") == nil
    end

    test "returns nil for invalid second" do
      assert DTM.parse("20260322143061") == nil
    end
  end

  describe "encode/1" do
    test "encodes year-only" do
      assert DTM.encode(%DTM{year: 2026}) == "2026"
    end

    test "encodes year-month" do
      assert DTM.encode(%DTM{year: 2026, month: 3}) == "202603"
    end

    test "encodes year-month-day" do
      assert DTM.encode(%DTM{year: 2026, month: 3, day: 22}) == "20260322"
    end

    test "encodes with time" do
      assert DTM.encode(%DTM{year: 2026, month: 3, day: 22, hour: 14, minute: 30}) ==
               "202603221430"
    end

    test "encodes with seconds" do
      assert DTM.encode(%DTM{
               year: 2026,
               month: 3,
               day: 22,
               hour: 14,
               minute: 30,
               second: 22
             }) == "20260322143022"
    end

    test "encodes with fraction and offset" do
      assert DTM.encode(%DTM{
               year: 2026,
               month: 3,
               day: 22,
               hour: 14,
               minute: 30,
               second: 22,
               fraction: "1234",
               offset: "+0100"
             }) == "20260322143022.1234+0100"
    end

    test "returns empty string for nil" do
      assert DTM.encode(nil) == ""
    end
  end

  describe "round-trip" do
    test "full precision round-trip" do
      str = "20260322143022.1234+0100"
      assert str |> DTM.parse() |> DTM.encode() == str
    end

    test "year-only round-trip" do
      assert "2026" |> DTM.parse() |> DTM.encode() == "2026"
    end

    test "day precision round-trip" do
      assert "20260322" |> DTM.parse() |> DTM.encode() == "20260322"
    end

    test "minute precision round-trip" do
      assert "202603221430" |> DTM.parse() |> DTM.encode() == "202603221430"
    end

    test "with negative offset round-trip" do
      assert "202603221430-0500" |> DTM.parse() |> DTM.encode() == "202603221430-0500"
    end
  end
end
