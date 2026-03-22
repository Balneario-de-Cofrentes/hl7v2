defmodule HL7v2.Segment.AISTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.AIS

  describe "fields/0" do
    test "returns 12 field definitions" do
      assert length(AIS.fields()) == 12
    end
  end

  describe "segment_id/0" do
    test "returns AIS" do
      assert AIS.segment_id() == "AIS"
    end
  end

  describe "parse/1" do
    test "parses with service info" do
      raw = [
        "1",
        "A",
        ["CONSULT", "Consultation", "L"]
      ]

      result = AIS.parse(raw)

      assert %AIS{} = result
      assert result.set_id == 1
      assert result.segment_action_code == "A"

      assert %HL7v2.Type.CE{
               identifier: "CONSULT",
               text: "Consultation",
               name_of_coding_system: "L"
             } = result.universal_service_identifier
    end

    test "parses start_date_time as TS" do
      raw = ["1", "", ["CONSULT", "Consultation"], ["20260401090000"]]

      result = AIS.parse(raw)

      assert %HL7v2.Type.TS{
               time: %HL7v2.Type.DTM{
                 year: 2026,
                 month: 4,
                 day: 1,
                 hour: 9,
                 minute: 0,
                 second: 0
               }
             } = result.start_date_time
    end

    test "parses duration as NM" do
      raw = ["1", "", ["CONSULT", "Consultation"], "", "", "", "30"]

      result = AIS.parse(raw)

      assert result.duration == "30"
    end

    test "parses duration_units as CE" do
      raw = ["1", "", ["CONSULT", "Consultation"], "", "", "", "30", ["min", "minutes"]]

      result = AIS.parse(raw)

      assert %HL7v2.Type.CE{identifier: "min", text: "minutes"} = result.duration_units
    end

    test "parses allow_substitution_code and filler_status_code" do
      raw = ["1", "", ["SVC", "Service"], "", "", "", "", "", "N", ["BOOKED", "Booked"]]

      result = AIS.parse(raw)

      assert result.allow_substitution_code == "N"
      assert %HL7v2.Type.CE{identifier: "BOOKED", text: "Booked"} = result.filler_status_code
    end

    test "parses empty list — all fields nil" do
      result = AIS.parse([])

      assert %AIS{} = result
      assert result.set_id == nil
      assert result.segment_action_code == nil
      assert result.universal_service_identifier == nil
      assert result.start_date_time == nil
      assert result.start_date_time_offset == nil
      assert result.start_date_time_offset_units == nil
      assert result.duration == nil
      assert result.duration_units == nil
      assert result.allow_substitution_code == nil
      assert result.filler_status_code == nil
      assert result.placer_supplemental_service_information == nil
      assert result.filler_supplemental_service_information == nil
    end
  end

  describe "encode/1" do
    test "round-trip with service info" do
      raw = [
        "1",
        "A",
        ["CONSULT", "Consultation", "L"]
      ]

      encoded = raw |> AIS.parse() |> AIS.encode()

      assert Enum.at(encoded, 0) == "1"
      assert Enum.at(encoded, 1) == "A"
      assert Enum.at(encoded, 2) == ["CONSULT", "Consultation", "L"]
    end

    test "round-trip with duration" do
      raw = ["1", "", ["CONSULT", "Consultation"], "", "", "", "30", ["min", "minutes"]]

      encoded = raw |> AIS.parse() |> AIS.encode()

      assert Enum.at(encoded, 6) == "30"
      assert Enum.at(encoded, 7) == ["min", "minutes"]
    end

    test "trailing nil fields trimmed" do
      ais = %AIS{set_id: 1, universal_service_identifier: %HL7v2.Type.CE{identifier: "SVC"}}

      encoded = AIS.encode(ais)

      assert length(encoded) == 3
    end

    test "encodes all-nil struct to empty list" do
      assert AIS.encode(%AIS{}) == []
    end
  end
end
