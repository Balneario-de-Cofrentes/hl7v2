defmodule HL7v2.Segment.OBRTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.OBR
  alias HL7v2.Type.{CE, EI, TS, DTM}

  describe "fields/0" do
    test "returns 49 field definitions" do
      assert length(OBR.fields()) == 49
    end
  end

  describe "segment_id/0" do
    test "returns OBR" do
      assert OBR.segment_id() == "OBR"
    end
  end

  describe "parse/1" do
    test "parses with order info" do
      raw =
        build_obr_fields(%{
          0 => "1",
          1 => ["ORD001", "PLACER"],
          2 => ["FILL001", "FILLER"],
          3 => ["85025", "CBC", "CPT4"]
        })

      result = OBR.parse(raw)

      assert %OBR{} = result
      assert result.set_id == 1

      assert %EI{entity_identifier: "ORD001", namespace_id: "PLACER"} =
               result.placer_order_number

      assert %EI{entity_identifier: "FILL001", namespace_id: "FILLER"} =
               result.filler_order_number

      assert %CE{identifier: "85025", text: "CBC", name_of_coding_system: "CPT4"} =
               result.universal_service_identifier
    end

    test "observation_date_time parsed as TS" do
      raw =
        build_obr_fields(%{
          3 => ["85025", "CBC", "CPT4"],
          6 => ["20260315083000"]
        })

      result = OBR.parse(raw)

      assert %TS{
               time: %DTM{year: 2026, month: 3, day: 15, hour: 8, minute: 30, second: 0}
             } = result.observation_date_time
    end

    test "raw fields preserved (ordering_provider, collector_identifier)" do
      provider_raw = "Smith^John^Q"
      collector_raw = [["TECH001", "Jones"]]

      raw =
        build_obr_fields(%{
          3 => ["85025", "CBC", "CPT4"],
          9 => collector_raw,
          15 => provider_raw
        })

      result = OBR.parse(raw)

      assert result.collector_identifier == collector_raw
      assert result.ordering_provider == provider_raw
    end

    test "result_status and diagnostic_serv_sect_id parsed" do
      raw =
        build_obr_fields(%{
          3 => ["85025", "CBC", "CPT4"],
          23 => "HM",
          24 => "F"
        })

      result = OBR.parse(raw)

      assert result.diagnostic_serv_sect_id == "HM"
      assert result.result_status == "F"
    end

    test "parses empty list — all fields nil" do
      result = OBR.parse([])

      assert %OBR{} = result
      assert result.set_id == nil
      assert result.placer_order_number == nil
      assert result.filler_order_number == nil
      assert result.universal_service_identifier == nil
      assert result.observation_date_time == nil
    end
  end

  describe "encode/1" do
    test "round-trip: parse then encode preserves data" do
      raw =
        build_obr_fields(%{
          0 => "1",
          1 => ["ORD001", "PLACER"],
          2 => ["FILL001", "FILLER"],
          3 => ["85025", "CBC", "CPT4"]
        })

      encoded = raw |> OBR.parse() |> OBR.encode()

      assert Enum.at(encoded, 0) == "1"
      assert Enum.at(encoded, 1) == ["ORD001", "PLACER"]
      assert Enum.at(encoded, 2) == ["FILL001", "FILLER"]
      assert Enum.at(encoded, 3) == ["85025", "CBC", "CPT4"]
    end

    test "round-trip with raw ordering_provider" do
      raw =
        build_obr_fields(%{
          3 => ["85025", "CBC", "CPT4"],
          15 => "DrSmith^John"
        })

      encoded = raw |> OBR.parse() |> OBR.encode()

      assert Enum.at(encoded, 15) == "DrSmith^John"
    end

    test "trailing nil fields are trimmed" do
      obr = %OBR{set_id: 1}

      encoded = OBR.encode(obr)

      assert encoded == ["1"]
    end

    test "encodes all-nil struct to empty list" do
      assert OBR.encode(%OBR{}) == []
    end
  end

  defp build_obr_fields(overrides) do
    Enum.map(0..48, fn i -> Map.get(overrides, i) end)
  end
end
