defmodule HL7v2.Segment.APRTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.APR

  describe "fields/0" do
    test "returns 5 field definitions" do
      assert length(APR.fields()) == 5
    end
  end

  describe "segment_id/0" do
    test "returns APR" do
      assert APR.segment_id() == "APR"
    end
  end

  describe "parse/1" do
    test "parses slot_spacing_criteria as NM" do
      raw = ["", "", "", "30"]

      result = APR.parse(raw)

      assert %APR{} = result
      assert %HL7v2.Type.NM{value: "30"} = result.slot_spacing_criteria
    end

    test "parses typed criteria fields as SCV" do
      raw = [["MON", "Monday"], "", "", ""]

      result = APR.parse(raw)

      assert [%HL7v2.Type.SCV{parameter_value: "Monday"}] = result.time_selection_criteria
    end

    test "parses empty list" do
      result = APR.parse([])

      assert %APR{} = result
      assert result.time_selection_criteria == nil
      assert result.slot_spacing_criteria == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert APR.encode(%APR{}) == []
    end

    test "round-trip preserves data" do
      raw = ["", "", "", "30"]

      encoded = raw |> APR.parse() |> APR.encode()

      assert Enum.at(encoded, 3) == "30"
    end
  end
end
