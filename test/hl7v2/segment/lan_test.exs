defmodule HL7v2.Segment.LANTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.LAN

  describe "fields/0" do
    test "returns 4 field definitions" do
      assert length(LAN.fields()) == 4
    end
  end

  describe "segment_id/0" do
    test "returns LAN" do
      assert LAN.segment_id() == "LAN"
    end
  end

  describe "parse/1" do
    test "parses language info" do
      raw = ["1", ["EN", "English"], "", ["4", "Fluent"]]

      result = LAN.parse(raw)

      assert result.set_id == 1
      assert %HL7v2.Type.CE{identifier: "EN", text: "English"} = result.language_code
      assert %HL7v2.Type.CE{identifier: "4", text: "Fluent"} = result.language_proficiency_code
    end

    test "parses empty list" do
      result = LAN.parse([])

      assert %LAN{} = result
      assert result.set_id == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert LAN.encode(%LAN{}) == []
    end

    test "round-trip preserves data" do
      raw = ["1", ["EN", "English"]]

      encoded = raw |> LAN.parse() |> LAN.encode()

      assert Enum.at(encoded, 0) == "1"
      assert Enum.at(encoded, 1) == ["EN", "English"]
    end
  end
end
