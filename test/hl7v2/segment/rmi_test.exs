defmodule HL7v2.Segment.RMITest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.RMI

  describe "fields/0" do
    test "returns 3 field definitions" do
      assert length(RMI.fields()) == 3
    end
  end

  describe "segment_id/0" do
    test "returns RMI" do
      assert RMI.segment_id() == "RMI"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = RMI.parse([])
      assert %RMI{} = result
      assert result.risk_management_incident_code == nil
    end

    test "parses all fields" do
      raw = [["FALL", "Patient Fall"], ["20260326120000"], ["ACC", "Accident"]]
      result = RMI.parse(raw)

      assert %HL7v2.Type.CE{identifier: "FALL"} = result.risk_management_incident_code
      assert %HL7v2.Type.TS{} = result.date_time_incident

      assert %HL7v2.Type.DTM{year: 2026, month: 3, day: 26, hour: 12} =
               result.date_time_incident.time

      assert %HL7v2.Type.CE{identifier: "ACC"} = result.incident_type_code
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [["FALL", "Patient Fall"], ["20260326120000"], ["ACC", "Accident"]]
      encoded = raw |> RMI.parse() |> RMI.encode()
      reparsed = RMI.parse(encoded)
      assert reparsed.risk_management_incident_code.identifier == "FALL"
      assert reparsed.incident_type_code.identifier == "ACC"
    end

    test "encodes all-nil struct to empty list" do
      assert RMI.encode(%RMI{}) == []
    end
  end
end
