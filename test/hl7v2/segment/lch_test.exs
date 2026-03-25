defmodule HL7v2.Segment.LCHTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.LCH

  describe "fields/0" do
    test "returns 4 field definitions" do
      assert length(LCH.fields()) == 4
    end
  end

  describe "segment_id/0" do
    test "returns LCH" do
      assert LCH.segment_id() == "LCH"
    end
  end

  describe "parse/1" do
    test "parses location characteristic" do
      raw = [["WARD", "301"], "", ["SMK", "Smoking"], ["N", "Non-smoking"]]

      result = LCH.parse(raw)

      assert %LCH{} = result
      assert %HL7v2.Type.PL{point_of_care: "WARD"} = result.primary_key_value
      assert %HL7v2.Type.CE{identifier: "SMK"} = result.location_characteristic_id
      assert %HL7v2.Type.CE{identifier: "N"} = result.location_characteristic_value
    end

    test "parses empty list" do
      result = LCH.parse([])

      assert %LCH{} = result
      assert result.primary_key_value == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert LCH.encode(%LCH{}) == []
    end
  end
end
