defmodule HL7v2.Segment.PSHTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.PSH

  describe "fields/0" do
    test "returns 14 field definitions" do
      assert length(PSH.fields()) == 14
    end
  end

  describe "segment_id/0" do
    test "returns PSH" do
      assert PSH.segment_id() == "PSH"
    end
  end

  describe "parse/1" do
    test "parses report_type" do
      raw = ["Annual Report"]

      result = PSH.parse(raw)

      assert %PSH{} = result
      assert result.report_type == "Annual Report"
    end

    test "parses empty list" do
      result = PSH.parse([])

      assert %PSH{} = result
      assert result.report_type == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert PSH.encode(%PSH{}) == []
    end
  end
end
