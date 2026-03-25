defmodule HL7v2.Segment.PRATest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.PRA

  describe "fields/0" do
    test "returns 12 field definitions" do
      assert length(PRA.fields()) == 12
    end
  end

  describe "segment_id/0" do
    test "returns PRA" do
      assert PRA.segment_id() == "PRA"
    end
  end

  describe "parse/1" do
    test "parses primary_key_value and provider_billing" do
      raw = [["DR001", "Dr. Smith"], "", "", "Y"]

      result = PRA.parse(raw)

      assert %PRA{} = result
      assert %HL7v2.Type.CE{identifier: "DR001"} = result.primary_key_value
      assert result.provider_billing == "Y"
    end

    test "parses date_entered_practice" do
      raw = List.duplicate("", 7) ++ ["20100115"]

      result = PRA.parse(raw)

      assert result.date_entered_practice == ~D[2010-01-15]
    end

    test "parses empty list" do
      result = PRA.parse([])

      assert %PRA{} = result
      assert result.primary_key_value == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert PRA.encode(%PRA{}) == []
    end
  end
end
