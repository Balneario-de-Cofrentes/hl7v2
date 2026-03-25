defmodule HL7v2.Segment.URDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.URD

  describe "fields/0" do
    test "returns 7 field definitions" do
      assert length(URD.fields()) == 7
    end
  end

  describe "segment_id/0" do
    test "returns URD" do
      assert URD.segment_id() == "URD"
    end
  end

  describe "parse/1" do
    test "parses report_priority" do
      raw = ["", "R"]

      result = URD.parse(raw)

      assert %URD{} = result
      assert result.report_priority == "R"
    end

    test "parses r_u_results_level" do
      raw = List.duplicate("", 6) ++ ["T"]

      result = URD.parse(raw)

      assert result.r_u_results_level == "T"
    end

    test "parses empty list" do
      result = URD.parse([])

      assert %URD{} = result
      assert result.r_u_date_time == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert URD.encode(%URD{}) == []
    end
  end
end
