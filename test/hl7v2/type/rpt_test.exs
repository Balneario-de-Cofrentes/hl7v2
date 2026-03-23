defmodule HL7v2.Type.RPTTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.RPT
  alias HL7v2.Type.CWE
  alias HL7v2.Type.NM

  doctest RPT

  describe "parse/1" do
    test "parses repeat pattern code only" do
      result = RPT.parse(["QAM&Every morning&HL70335"])

      assert %CWE{
               identifier: "QAM",
               text: "Every morning",
               name_of_coding_system: "HL70335"
             } = result.repeat_pattern_code

      assert result.calendar_alignment == nil
      assert result.period_quantity == nil
    end

    test "parses full RPT with period" do
      result = RPT.parse(["Q6H&Every 6 hours&HL70335", "DY", "", "", "6", "h"])

      assert %CWE{identifier: "Q6H"} = result.repeat_pattern_code
      assert result.calendar_alignment == "DY"
      assert result.phase_range_begin_value == nil
      assert result.phase_range_end_value == nil
      assert %NM{value: "6"} = result.period_quantity
      assert result.period_units == "h"
    end

    test "parses RPT with phase range" do
      result = RPT.parse(["BID&Twice daily&HL70335", "DY", "8", "20"])

      assert %CWE{identifier: "BID"} = result.repeat_pattern_code
      assert result.calendar_alignment == "DY"
      assert %NM{value: "8"} = result.phase_range_begin_value
      assert %NM{value: "20"} = result.phase_range_end_value
    end

    test "parses simple code without sub-components" do
      result = RPT.parse(["QD"])

      assert %CWE{identifier: "QD"} = result.repeat_pattern_code
    end

    test "parses empty list" do
      result = RPT.parse([])
      assert result.repeat_pattern_code == nil
      assert result.calendar_alignment == nil
      assert result.phase_range_begin_value == nil
      assert result.phase_range_end_value == nil
      assert result.period_quantity == nil
      assert result.period_units == nil
    end
  end

  describe "encode/1" do
    test "encodes full RPT" do
      rpt = %RPT{
        repeat_pattern_code: %CWE{
          identifier: "Q6H",
          text: "Every 6 hours",
          name_of_coding_system: "HL70335"
        },
        calendar_alignment: "DY",
        period_quantity: %NM{value: "6", original: "6"},
        period_units: "h"
      }

      assert RPT.encode(rpt) == ["Q6H&Every 6 hours&HL70335", "DY", "", "", "6", "h"]
    end

    test "encodes pattern code only" do
      rpt = %RPT{
        repeat_pattern_code: %CWE{
          identifier: "QAM",
          text: "Every morning",
          name_of_coding_system: "HL70335"
        }
      }

      assert RPT.encode(rpt) == ["QAM&Every morning&HL70335"]
    end

    test "encodes nil" do
      assert RPT.encode(nil) == []
    end

    test "encodes empty struct" do
      assert RPT.encode(%RPT{}) == []
    end
  end

  describe "round-trip" do
    test "full RPT round-trips" do
      components = ["Q6H&Every 6 hours&HL70335", "DY", "", "", "6", "h"]
      assert components |> RPT.parse() |> RPT.encode() == components
    end

    test "pattern-only round-trips" do
      components = ["QAM&Every morning&HL70335"]
      assert components |> RPT.parse() |> RPT.encode() == components
    end

    test "RPT with phase range round-trips" do
      components = ["BID&Twice daily&HL70335", "DY", "8", "20"]
      assert components |> RPT.parse() |> RPT.encode() == components
    end
  end
end
