defmodule HL7v2.Segment.URSTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.URS

  describe "fields/0" do
    test "returns 8 field definitions" do
      assert length(URS.fields()) == 8
    end
  end

  describe "segment_id/0" do
    test "returns URS" do
      assert URS.segment_id() == "URS"
    end
  end

  describe "parse/1" do
    test "parses where_subject_definition" do
      raw = [["OBR"]]

      result = URS.parse(raw)

      assert %URS{} = result
      assert ["OBR"] = result.r_u_where_subject_definition
    end

    test "parses empty list" do
      result = URS.parse([])

      assert %URS{} = result
      assert result.r_u_where_subject_definition == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert URS.encode(%URS{}) == []
    end
  end
end
