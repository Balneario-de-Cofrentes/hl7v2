defmodule HL7v2.Segment.ORCTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.ORC
  alias HL7v2.Type.EI

  describe "fields/0" do
    test "returns 31 field definitions" do
      assert length(ORC.fields()) == 31
    end
  end

  describe "segment_id/0" do
    test "returns ORC" do
      assert ORC.segment_id() == "ORC"
    end
  end

  describe "parse/1" do
    test "parses order_control, placer and filler order numbers" do
      raw = build_orc_fields(%{
        0 => "NW",
        1 => ["ORD001", "PLACER"],
        2 => ["FILL001", "FILLER"]
      })

      result = ORC.parse(raw)

      assert %ORC{} = result
      assert result.order_control == "NW"

      assert %EI{entity_identifier: "ORD001", namespace_id: "PLACER"} =
               result.placer_order_number

      assert %EI{entity_identifier: "FILL001", namespace_id: "FILLER"} =
               result.filler_order_number
    end

    test "parses order_status and response_flag" do
      raw = build_orc_fields(%{
        0 => "SC",
        4 => "CM",
        5 => "D"
      })

      result = ORC.parse(raw)

      assert result.order_control == "SC"
      assert result.order_status == "CM"
      assert result.response_flag == "D"
    end

    test "raw fields (ordering_provider, entered_by) preserved as-is" do
      provider_raw = "Smith^John"
      entered_raw = [["Jones", "Mary"]]

      raw = build_orc_fields(%{
        0 => "NW",
        9 => entered_raw,
        11 => provider_raw
      })

      result = ORC.parse(raw)

      assert result.entered_by == entered_raw
      assert result.ordering_provider == provider_raw
    end

    test "parses empty list — all fields nil" do
      result = ORC.parse([])

      assert %ORC{} = result
      assert result.order_control == nil
      assert result.placer_order_number == nil
      assert result.filler_order_number == nil
    end

    test "parses empty string fields as nil" do
      raw = List.duplicate("", 31)

      result = ORC.parse(raw)

      assert result.order_control == nil
      assert result.placer_order_number == nil
    end
  end

  describe "encode/1" do
    test "round-trip: parse then encode preserves data" do
      raw = build_orc_fields(%{
        0 => "NW",
        1 => ["ORD001", "PLACER"],
        2 => ["FILL001", "FILLER"]
      })

      encoded = raw |> ORC.parse() |> ORC.encode()

      assert Enum.at(encoded, 0) == "NW"
      assert Enum.at(encoded, 1) == ["ORD001", "PLACER"]
      assert Enum.at(encoded, 2) == ["FILL001", "FILLER"]
    end

    test "round-trip with placer_group_number" do
      raw = build_orc_fields(%{
        0 => "NW",
        1 => ["ORD001"],
        3 => ["GRP001", "HOSP"]
      })

      encoded = raw |> ORC.parse() |> ORC.encode()

      assert Enum.at(encoded, 0) == "NW"
      assert Enum.at(encoded, 3) == ["GRP001", "HOSP"]
    end

    test "trailing nil fields are trimmed" do
      orc = %ORC{order_control: "NW"}

      encoded = ORC.encode(orc)

      assert encoded == ["NW"]
    end

    test "encodes all-nil struct to empty list" do
      assert ORC.encode(%ORC{}) == []
    end
  end

  defp build_orc_fields(overrides) do
    Enum.map(0..30, fn i -> Map.get(overrides, i) end)
  end
end
