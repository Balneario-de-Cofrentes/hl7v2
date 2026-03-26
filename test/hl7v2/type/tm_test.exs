defmodule HL7v2.Type.TMTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.TM

  doctest TM

  describe "parse/1" do
    test "parses full time with fraction and offset" do
      result = TM.parse("143022.1234+0100")

      assert %TM{
               hour: 14,
               minute: 30,
               second: 22,
               fraction: "1234",
               offset: "+0100"
             } = result
    end

    test "parses hour only" do
      assert %TM{hour: 14, minute: nil, second: nil} = TM.parse("14")
    end

    test "parses hour and minute" do
      assert %TM{hour: 14, minute: 30, second: nil} = TM.parse("1430")
    end

    test "parses hour, minute, second" do
      assert %TM{hour: 14, minute: 30, second: 22} = TM.parse("143022")
    end

    test "parses with negative offset" do
      result = TM.parse("143022-0500")
      assert result.hour == 14
      assert result.minute == 30
      assert result.second == 22
      assert result.offset == "-0500"
    end

    test "parses hour with offset" do
      result = TM.parse("14+0100")
      assert result.hour == 14
      assert result.offset == "+0100"
    end

    test "parses with fraction" do
      result = TM.parse("143022.12")
      assert result.second == 22
      assert result.fraction == "12"
    end

    test "parses single-digit fraction" do
      result = TM.parse("143022.5")
      assert result.fraction == "5"
    end

    test "returns nil for empty string" do
      assert TM.parse("") == nil
    end

    test "returns nil for nil" do
      assert TM.parse(nil) == nil
    end

    test "preserves invalid hour in original field" do
      assert %TM{original: "25"} = TM.parse("25")
    end

    test "preserves invalid minute in original field" do
      assert %TM{original: "1460"} = TM.parse("1460")
    end

    test "preserves invalid second in original field" do
      assert %TM{original: "143061"} = TM.parse("143061")
    end

    test "preserves too-short input in original field" do
      assert %TM{original: "1"} = TM.parse("1")
    end

    test "preserves non-numeric input in original field" do
      assert %TM{original: "AB"} = TM.parse("AB")
    end

    test "midnight" do
      assert %TM{hour: 0, minute: 0, second: 0} = TM.parse("000000")
    end

    test "end of day" do
      assert %TM{hour: 23, minute: 59, second: 59} = TM.parse("235959")
    end
  end

  describe "encode/1" do
    test "encodes full time" do
      tm = %TM{hour: 14, minute: 30, second: 22, fraction: "1234", offset: "+0100"}
      assert TM.encode(tm) == "143022.1234+0100"
    end

    test "encodes hour only" do
      assert TM.encode(%TM{hour: 14}) == "14"
    end

    test "encodes hour and minute" do
      assert TM.encode(%TM{hour: 14, minute: 30}) == "1430"
    end

    test "encodes hour, minute, second" do
      assert TM.encode(%TM{hour: 14, minute: 30, second: 22}) == "143022"
    end

    test "encodes with offset, no fraction" do
      assert TM.encode(%TM{hour: 14, minute: 30, second: 22, offset: "-0500"}) ==
               "143022-0500"
    end

    test "encodes nil" do
      assert TM.encode(nil) == ""
    end

    test "pads single-digit values" do
      assert TM.encode(%TM{hour: 8, minute: 5, second: 3}) == "080503"
    end
  end

  describe "round-trip" do
    test "full time round-trips" do
      input = "143022.1234+0100"
      assert input |> TM.parse() |> TM.encode() == input
    end

    test "hour-only round-trips" do
      input = "14"
      assert input |> TM.parse() |> TM.encode() == input
    end

    test "hour-minute round-trips" do
      input = "1430"
      assert input |> TM.parse() |> TM.encode() == input
    end

    test "time with offset round-trips" do
      input = "143022-0500"
      assert input |> TM.parse() |> TM.encode() == input
    end

    test "midnight round-trips" do
      input = "000000"
      assert input |> TM.parse() |> TM.encode() == input
    end
  end
end
