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

    test "preserves malformed timezone offset for lossless round-trip" do
      result = DTM.parse("202603221430+ABCD")

      assert result == %DTM{
               year: 2026,
               month: 3,
               day: 22,
               hour: 14,
               minute: 30,
               offset: "+ABCD"
             }

      assert DTM.encode(result) == "202603221430+ABCD"
    end

    test "preserves out-of-range hours in timezone offset" do
      result = DTM.parse("202603221430+2500")

      assert result == %DTM{
               year: 2026,
               month: 3,
               day: 22,
               hour: 14,
               minute: 30,
               offset: "+2500"
             }

      assert DTM.encode(result) == "202603221430+2500"
    end

    test "preserves out-of-range minutes in timezone offset" do
      result = DTM.parse("202603221430+0160")

      assert result == %DTM{
               year: 2026,
               month: 3,
               day: 22,
               hour: 14,
               minute: 30,
               offset: "+0160"
             }

      assert DTM.encode(result) == "202603221430+0160"
    end

    test "accepts valid timezone offsets" do
      assert DTM.parse("202603221430+0000").offset == "+0000"
      assert DTM.parse("202603221430-0500").offset == "-0500"
      assert DTM.parse("202603221430+1200").offset == "+1200"
      assert DTM.parse("202603221430+2359").offset == "+2359"
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

    test "encodes DateTime with UTC offset" do
      {:ok, dt, _} = DateTime.from_iso8601("2026-03-22T14:30:22Z")
      assert DTM.encode(dt) == "20260322143022+0000"
    end

    test "encodes DateTime with positive offset" do
      # DateTime.from_iso8601 converts to UTC, so utc_offset/std_offset are 0
      # The encode function uses utc_offset + std_offset for the offset string
      {:ok, dt, _} = DateTime.from_iso8601("2026-03-22T14:30:22+01:00")
      # This results in 13:30:22 UTC with +0000 offset
      assert DTM.encode(dt) == "20260322133022+0000"
    end

    test "encodes DateTime with negative offset" do
      {:ok, dt, _} = DateTime.from_iso8601("2026-03-22T14:30:22-05:00")
      # This results in 19:30:22 UTC with +0000 offset
      assert DTM.encode(dt) == "20260322193022+0000"
    end

    test "encodes DateTime with microseconds (capped at 4 digits per HL7 v2.5.1)" do
      {:ok, dt, _} = DateTime.from_iso8601("2026-03-22T14:30:22.123456Z")
      assert DTM.encode(dt) == "20260322143022.1234+0000"
    end

    test "encodes DateTime with zero microseconds omits fraction" do
      {:ok, dt, _} = DateTime.from_iso8601("2026-03-22T14:30:22Z")
      result = DTM.encode(dt)
      refute String.contains?(result, ".")
    end

    test "encodes NaiveDateTime without offset" do
      ndt = ~N[2026-03-22 14:30:22]
      assert DTM.encode(ndt) == "20260322143022"
    end

    test "encodes NaiveDateTime with microseconds (capped at 4 digits per HL7 v2.5.1)" do
      ndt = ~N[2026-03-22 14:30:22.123456]
      assert DTM.encode(ndt) == "20260322143022.1234"
    end

    test "encodes NaiveDateTime with zero microseconds omits fraction" do
      ndt = ~N[2026-03-22 14:30:22]
      result = DTM.encode(ndt)
      refute String.contains?(result, ".")
    end

    test "encodes DTM struct with hour only" do
      assert DTM.encode(%DTM{year: 2026, month: 3, day: 22, hour: 14}) == "2026032214"
    end
  end

  describe "parse/1 edge cases" do
    test "returns nil for non-digit year" do
      assert DTM.parse("ABCD") == nil
    end

    test "returns nil for 5 character input (odd length)" do
      assert DTM.parse("20261") == nil
    end

    test "returns nil for 7 character input (odd length)" do
      assert DTM.parse("2026031") == nil
    end

    test "returns nil for 9 character input (odd length between 8 and 10)" do
      assert DTM.parse("202603221") == nil
    end

    test "returns nil for 11 character input (odd length between 10 and 12)" do
      assert DTM.parse("20260322141") == nil
    end

    test "returns nil for 13 character input (odd length between 12 and 14)" do
      assert DTM.parse("2026032214301") == nil
    end

    test "returns nil for fraction longer than 4 digits" do
      assert DTM.parse("20260322143022.12345") == nil
    end

    test "returns nil for empty fraction after dot" do
      assert DTM.parse("20260322143022.") == nil
    end

    test "returns nil for non-digit fraction" do
      assert DTM.parse("20260322143022.abcd") == nil
    end

    test "parses seconds without fraction correctly" do
      result = DTM.parse("20260322143022")

      assert result == %DTM{
               year: 2026,
               month: 3,
               day: 22,
               hour: 14,
               minute: 30,
               second: 22
             }
    end

    test "returns nil for year 0" do
      assert DTM.parse("0000") == nil
    end

    test "returns nil for month 0" do
      assert DTM.parse("202600") == nil
    end

    test "parses Feb 29 in leap year" do
      result = DTM.parse("20240229")
      assert %DTM{year: 2024, month: 2, day: 29} = result
    end

    test "returns nil for Feb 29 in non-leap year" do
      assert DTM.parse("20250229") == nil
    end

    test "returns nil for non-digit in hour position" do
      assert DTM.parse("20260322AB") == nil
    end

    test "returns nil for non-digit in minute position" do
      assert DTM.parse("202603221430XX") == nil
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

    test "malformed offset round-trip preserves wire format" do
      assert "202603221430+ABCD" |> DTM.parse() |> DTM.encode() == "202603221430+ABCD"
      assert "202603221430+2500" |> DTM.parse() |> DTM.encode() == "202603221430+2500"
      assert "202603221430-9999" |> DTM.parse() |> DTM.encode() == "202603221430-9999"
    end
  end
end
