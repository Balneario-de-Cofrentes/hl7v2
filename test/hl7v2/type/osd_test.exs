defmodule HL7v2.Type.OSDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.OSD

  doctest OSD

  describe "parse/1" do
    test "parses order sequence" do
      result = OSD.parse(["S", "ORD001", "HOSP", "FILL001", "LAB"])
      assert result.sequence_results_flag == "S"
      assert result.placer_order_number_entity_identifier == "ORD001"
      assert result.filler_order_number_entity_identifier == "FILL001"
    end

    test "parses empty list" do
      assert OSD.parse([]).sequence_results_flag == nil
    end
  end

  describe "encode/1" do
    test "encodes OSD" do
      osd = %OSD{sequence_results_flag: "S", placer_order_number_entity_identifier: "ORD001"}
      assert OSD.encode(osd) == ["S", "ORD001"]
    end

    test "encodes nil" do
      assert OSD.encode(nil) == []
    end
  end

  describe "round-trip" do
    test "round-trips" do
      components = ["S", "ORD001", "HOSP", "FILL001", "LAB"]
      assert components |> OSD.parse() |> OSD.encode() == components
    end
  end
end
