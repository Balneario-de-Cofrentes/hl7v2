defmodule HL7v2.Segment.INVTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.INV

  describe "fields/0" do
    test "returns 20 field definitions" do
      assert length(INV.fields()) == 20
    end
  end

  describe "segment_id/0" do
    test "returns INV" do
      assert INV.segment_id() == "INV"
    end
  end

  describe "parse/1" do
    test "parses substance_identifier as CE" do
      raw = [["GLUC", "Glucose", "L"]]

      result = INV.parse(raw)

      assert %INV{} = result
      assert %HL7v2.Type.CE{identifier: "GLUC", text: "Glucose"} = result.substance_identifier
    end

    test "parses initial_quantity as NM" do
      raw = List.duplicate("", 6) ++ ["100"]

      result = INV.parse(raw)

      assert %HL7v2.Type.NM{value: "100"} = result.initial_quantity
    end

    test "parses empty list" do
      result = INV.parse([])

      assert %INV{} = result
      assert result.substance_identifier == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert INV.encode(%INV{}) == []
    end

    test "round-trip preserves substance_identifier" do
      raw = [["GLUC", "Glucose", "L"]]

      encoded = raw |> INV.parse() |> INV.encode()

      assert Enum.at(encoded, 0) == ["GLUC", "Glucose", "L"]
    end
  end
end
