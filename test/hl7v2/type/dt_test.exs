defmodule HL7v2.Type.DTTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias HL7v2.Type.DT

  doctest DT

  describe "parse/1" do
    test "parses full date YYYYMMDD" do
      assert DT.parse("19880704") == ~D[1988-07-04]
    end

    test "parses year-month YYYYMM" do
      assert DT.parse("199503") == %DT{year: 1995, month: 3}
    end

    test "parses year-only YYYY" do
      assert DT.parse("2026") == %DT{year: 2026}
    end

    test "returns nil for empty string" do
      assert DT.parse("") == nil
    end

    test "returns nil for nil" do
      assert DT.parse(nil) == nil
    end

    test "preserves invalid date in original field" do
      assert %DT{original: "20261332"} = DT.parse("20261332")
    end

    test "preserves invalid month in original field" do
      assert %DT{original: "202613"} = DT.parse("202613")
    end

    test "preserves non-numeric input in original field" do
      assert %DT{original: "abcd"} = DT.parse("abcd")
    end

    test "preserves wrong-length input in original field" do
      assert %DT{original: "202"} = DT.parse("202")
      assert %DT{original: "20260"} = DT.parse("20260")
      assert %DT{original: "2026032"} = DT.parse("2026032")
    end

    test "handles leap year correctly" do
      assert DT.parse("20240229") == ~D[2024-02-29]
      assert %DT{original: "20250229"} = DT.parse("20250229")
    end
  end

  describe "encode/1" do
    test "encodes Date to YYYYMMDD" do
      assert DT.encode(~D[1988-07-04]) == "19880704"
    end

    test "encodes partial date year-month" do
      assert DT.encode(%DT{year: 1995, month: 3}) == "199503"
    end

    test "encodes partial date year-only" do
      assert DT.encode(%DT{year: 2026}) == "2026"
    end

    test "encodes DT with all fields" do
      assert DT.encode(%DT{year: 2026, month: 3, day: 22}) == "20260322"
    end

    test "returns empty string for nil" do
      assert DT.encode(nil) == ""
    end

    test "pads single-digit months and days" do
      assert DT.encode(~D[2026-01-05]) == "20260105"
    end
  end

  describe "round-trip" do
    test "full date round-trip" do
      assert "19880704" |> DT.parse() |> DT.encode() == "19880704"
    end

    test "partial date year-month round-trip" do
      assert "199503" |> DT.parse() |> DT.encode() == "199503"
    end

    test "partial date year-only round-trip" do
      assert "2026" |> DT.parse() |> DT.encode() == "2026"
    end
  end

  property "Date round-trip" do
    check all(
            year <- integer(2000..2030),
            month <- integer(1..12),
            day <- integer(1..28)
          ) do
      str = DT.encode(%DT{year: year, month: month, day: day})
      assert DT.parse(str) == Date.new!(year, month, day)
    end
  end
end
