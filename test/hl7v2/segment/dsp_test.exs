defmodule HL7v2.Segment.DSPTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.DSP

  describe "fields/0" do
    test "returns 5 field definitions" do
      assert length(DSP.fields()) == 5
    end
  end

  describe "segment_id/0" do
    test "returns DSP" do
      assert DSP.segment_id() == "DSP"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = DSP.parse([])
      assert %DSP{} = result
      assert result.set_id == nil
      assert result.data_line == nil
    end

    test "parses display data" do
      result = DSP.parse(["1", "2", "Patient Name: John Doe", "Y", "RES001"])
      assert result.set_id == 1
      assert result.display_level == 2
      assert result.data_line == "Patient Name: John Doe"
      assert result.logical_break_point == "Y"
      assert result.result_id == "RES001"
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["1", nil, "Line of data", nil, "RES001"]
      encoded = raw |> DSP.parse() |> DSP.encode()
      reparsed = DSP.parse(encoded)
      assert reparsed.set_id == 1
      assert reparsed.data_line == "Line of data"
      assert reparsed.result_id == "RES001"
    end

    test "encodes all-nil struct to empty list" do
      assert DSP.encode(%DSP{}) == []
    end
  end
end
