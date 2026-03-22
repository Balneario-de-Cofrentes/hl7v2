defmodule HL7v2.Segment.PV2Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.PV2
  alias HL7v2.Type.{CE, DTM, PL, TS}

  describe "field count" do
    test "defines 49 fields" do
      assert length(PV2.fields()) == 49
    end
  end

  describe "parse/1" do
    test "parses prior_pending_location" do
      raw = [["ICU", "101", "A"]]

      pv2 = PV2.parse(raw)

      assert %PL{point_of_care: "ICU", room: "101", bed: "A"} = pv2.prior_pending_location
    end

    test "parses admit reason and expected dates" do
      raw = [
        nil,
        nil,
        ["CHF", "Congestive Heart Failure"],
        nil,
        nil,
        nil,
        nil,
        ["20260401"]
      ]

      pv2 = PV2.parse(raw)

      assert %CE{identifier: "CHF", text: "Congestive Heart Failure"} = pv2.admit_reason
      assert %TS{time: %DTM{year: 2026, month: 4, day: 1}} = pv2.expected_admit_date_time
    end

    test "parses accommodation code" do
      raw = [
        nil,
        ["SP", "Semi-Private"]
      ]

      pv2 = PV2.parse(raw)

      assert %CE{identifier: "SP", text: "Semi-Private"} = pv2.accommodation_code
    end

    test "returns nil for missing optional fields" do
      pv2 = PV2.parse([])

      assert pv2.prior_pending_location == nil
      assert pv2.accommodation_code == nil
      assert pv2.admit_reason == nil
      assert pv2.expected_admit_date_time == nil
      assert pv2.visit_description == nil
    end

    test "parses empty list" do
      pv2 = PV2.parse([])

      assert %PV2{} = pv2
      assert pv2.prior_pending_location == nil
    end
  end

  describe "encode/1" do
    test "encodes PV2 with admit reason" do
      pv2 = %PV2{
        admit_reason: %CE{identifier: "CHF", text: "Congestive Heart Failure"},
        expected_admit_date_time: %TS{time: %DTM{year: 2026, month: 4, day: 1}}
      }

      encoded = PV2.encode(pv2)

      # Fields 1-2 are empty, field 3 is admit_reason, fields 4-7 empty, field 8 is expected_admit_date_time
      assert Enum.at(encoded, 2) == ["CHF", "Congestive Heart Failure"]
      assert Enum.at(encoded, 7) == ["20260401"]
    end

    test "encodes nil segment fields" do
      pv2 = %PV2{}
      encoded = PV2.encode(pv2)

      assert encoded == []
    end
  end

  describe "round-trip" do
    test "parse then encode preserves admit reason and expected admit date" do
      raw = [
        nil,
        nil,
        ["CHF", "Congestive Heart Failure"],
        nil,
        nil,
        nil,
        nil,
        ["20260401"]
      ]

      result = raw |> PV2.parse() |> PV2.encode()

      assert Enum.at(result, 2) == ["CHF", "Congestive Heart Failure"]
      assert Enum.at(result, 7) == ["20260401"]
    end

    test "parse then encode preserves location" do
      raw = [["ICU", "101", "A"]]

      result = raw |> PV2.parse() |> PV2.encode()

      assert Enum.at(result, 0) == ["ICU", "101", "A"]
    end
  end
end
