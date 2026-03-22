defmodule HL7v2.Type.DRTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.DR
  alias HL7v2.Type.{TS, DTM}

  doctest DR

  describe "parse/1" do
    test "parses both range start and end" do
      result = DR.parse(["20260101", "20261231"])

      assert %TS{time: %DTM{year: 2026, month: 1, day: 1}} = result.range_start
      assert %TS{time: %DTM{year: 2026, month: 12, day: 31}} = result.range_end
    end

    test "parses with only range start (open-ended)" do
      result = DR.parse(["20260101"])

      assert %TS{time: %DTM{year: 2026}} = result.range_start
      assert result.range_end == nil
    end

    test "parses with only range end" do
      result = DR.parse(["", "20261231"])

      assert result.range_start == nil
      assert %TS{time: %DTM{year: 2026, month: 12, day: 31}} = result.range_end
    end

    test "parses empty list" do
      result = DR.parse([])

      assert %DR{range_start: nil, range_end: nil} = result
    end
  end

  describe "encode/1" do
    test "encodes nil returns empty list" do
      assert DR.encode(nil) == []
    end

    test "encodes empty struct returns empty list" do
      assert DR.encode(%DR{}) == []
    end

    test "encodes both range start and end" do
      dr = %DR{
        range_start: %TS{time: %DTM{year: 2026, month: 1, day: 1}},
        range_end: %TS{time: %DTM{year: 2026, month: 12, day: 31}}
      }

      assert DR.encode(dr) == ["20260101", "20261231"]
    end

    test "encodes with only range start" do
      dr = %DR{
        range_start: %TS{time: %DTM{year: 2026, month: 1, day: 1}}
      }

      assert DR.encode(dr) == ["20260101"]
    end

    test "encodes with only range end" do
      dr = %DR{
        range_end: %TS{time: %DTM{year: 2026, month: 12, day: 31}}
      }

      assert DR.encode(dr) == ["", "20261231"]
    end

    test "encodes TS with empty time" do
      dr = %DR{
        range_start: %TS{},
        range_end: %TS{time: %DTM{year: 2026}}
      }

      assert DR.encode(dr) == ["", "2026"]
    end

    test "encode round-trip preserves data" do
      original = %DR{
        range_start: %TS{time: %DTM{year: 2025, month: 6, day: 15}},
        range_end: %TS{time: %DTM{year: 2026, month: 3, day: 22}}
      }

      parsed = original |> DR.encode() |> DR.parse()

      assert parsed.range_start.time.year == 2025
      assert parsed.range_start.time.month == 6
      assert parsed.range_end.time.year == 2026
      assert parsed.range_end.time.month == 3
    end
  end
end
