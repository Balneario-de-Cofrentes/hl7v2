defmodule HL7v2.Segment.ERRTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.ERR

  describe "fields/0" do
    test "returns 12 field definitions" do
      assert length(ERR.fields()) == 12
    end
  end

  describe "segment_id/0" do
    test "returns ERR" do
      assert ERR.segment_id() == "ERR"
    end
  end

  describe "parse/1" do
    test "parses hl7_error_code (CWE) and severity (ID)" do
      raw = [
        "",
        "",
        ["207", "Application internal error", "HL70357"],
        "E"
      ]

      result = ERR.parse(raw)

      assert %ERR{} = result

      assert %HL7v2.Type.CWE{
               identifier: "207",
               text: "Application internal error",
               name_of_coding_system: "HL70357"
             } = result.hl7_error_code

      assert result.severity == "E"
    end

    test "parses error_code_and_location as ELD and error_location as ERL" do
      error_location_data = [["PID", "1", "5"]]

      raw = [
        ["PID", "1", "3", "101&Required field missing&HL70357"],
        error_location_data,
        ["100", "Segment sequence error", "HL70357"],
        "W"
      ]

      result = ERR.parse(raw)

      assert [
               %HL7v2.Type.ELD{
                 segment_id: "PID",
                 segment_sequence: "1",
                 field_position: "3",
                 code_identifying_error: %HL7v2.Type.CE{
                   identifier: "101",
                   text: "Required field missing",
                   name_of_coding_system: "HL70357"
                 }
               }
             ] = result.error_code_and_location

      assert [
               %HL7v2.Type.ERL{
                 segment_id: "PID",
                 segment_sequence: %HL7v2.Type.NM{value: "1"},
                 field_position: %HL7v2.Type.NM{value: "5"}
               }
             ] = result.error_location

      assert result.severity == "W"
    end

    test "parses diagnostic_information as TX" do
      raw = [
        "",
        "",
        ["101", "Required field missing", "HL70357"],
        "E",
        "",
        "",
        "PID-3 is required but was not provided"
      ]

      result = ERR.parse(raw)

      assert result.diagnostic_information == "PID-3 is required but was not provided"
    end

    test "parses application_error_code as CWE" do
      raw = [
        "",
        "",
        ["207", "Application internal error", "HL70357"],
        "E",
        ["CUSTOM01", "Custom validation failed", "L"]
      ]

      result = ERR.parse(raw)

      assert %HL7v2.Type.CWE{identifier: "CUSTOM01", text: "Custom validation failed"} =
               result.application_error_code
    end

    test "parses user_message as TX" do
      raw = ["", "", ["207", "Error", "HL70357"], "E", "", "", "", "Please contact support"]

      result = ERR.parse(raw)

      assert result.user_message == "Please contact support"
    end

    test "parses empty list — all fields nil" do
      result = ERR.parse([])

      assert %ERR{} = result
      assert result.error_code_and_location == nil
      assert result.error_location == nil
      assert result.hl7_error_code == nil
      assert result.severity == nil
      assert result.application_error_code == nil
      assert result.application_error_parameter == nil
      assert result.diagnostic_information == nil
      assert result.user_message == nil
      assert result.inform_person_indicator == nil
      assert result.override_type == nil
      assert result.override_reason_code == nil
      assert result.help_desk_contact_point == nil
    end
  end

  describe "encode/1" do
    test "round-trip with error code and severity" do
      raw = [
        "",
        "",
        ["207", "Application internal error", "HL70357"],
        "E"
      ]

      encoded = raw |> ERR.parse() |> ERR.encode()

      assert Enum.at(encoded, 0) == ""
      assert Enum.at(encoded, 1) == ""
      assert Enum.at(encoded, 2) == ["207", "Application internal error", "HL70357"]
      assert Enum.at(encoded, 3) == "E"
    end

    test "round-trip with diagnostic_information" do
      raw = [
        "",
        "",
        ["101", "Required field missing", "HL70357"],
        "E",
        "",
        "",
        "PID-3 is required"
      ]

      encoded = raw |> ERR.parse() |> ERR.encode()

      assert Enum.at(encoded, 6) == "PID-3 is required"
    end

    test "trailing nil fields trimmed" do
      err = %ERR{
        hl7_error_code: %HL7v2.Type.CWE{identifier: "207"},
        severity: "E"
      }

      encoded = ERR.encode(err)

      # error_code_and_location and error_location are nil -> ""
      assert length(encoded) == 4
      assert Enum.at(encoded, 3) == "E"
    end

    test "encodes all-nil struct to empty list" do
      assert ERR.encode(%ERR{}) == []
    end
  end
end
