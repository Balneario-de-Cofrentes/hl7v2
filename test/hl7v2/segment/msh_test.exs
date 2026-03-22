defmodule HL7v2.Segment.MSHTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.MSH

  describe "fields/0" do
    test "returns 21 field definitions" do
      assert length(MSH.fields()) == 21
    end
  end

  describe "segment_id/0" do
    test "returns MSH" do
      assert MSH.segment_id() == "MSH"
    end
  end

  describe "parse/1" do
    @raw_msh [
      "|",
      "^~\\&",
      ["SEND", "", ""],
      ["FAC", "", ""],
      "",
      "",
      ["20260322120000"],
      "",
      ["ADT", "A01", "ADT_A01"],
      "MSG001",
      ["P"],
      ["2.5.1"]
    ]

    test "parses field_separator as literal string" do
      result = MSH.parse(@raw_msh)

      assert result.field_separator == "|"
    end

    test "parses encoding_characters as literal string" do
      result = MSH.parse(@raw_msh)

      assert result.encoding_characters == "^~\\&"
    end

    test "parses sending_application as HD" do
      result = MSH.parse(@raw_msh)

      assert %HL7v2.Type.HD{namespace_id: "SEND"} = result.sending_application
    end

    test "parses sending_facility as HD" do
      result = MSH.parse(@raw_msh)

      assert %HL7v2.Type.HD{namespace_id: "FAC"} = result.sending_facility
    end

    test "parses date_time_of_message as TS" do
      result = MSH.parse(@raw_msh)

      assert %HL7v2.Type.TS{
               time: %HL7v2.Type.DTM{
                 year: 2026,
                 month: 3,
                 day: 22,
                 hour: 12,
                 minute: 0,
                 second: 0
               }
             } = result.date_time_of_message
    end

    test "parses message_type as MSG struct" do
      result = MSH.parse(@raw_msh)

      assert %HL7v2.Type.MSG{
               message_code: "ADT",
               trigger_event: "A01",
               message_structure: "ADT_A01"
             } = result.message_type
    end

    test "parses message_control_id as ST" do
      result = MSH.parse(@raw_msh)

      assert result.message_control_id == "MSG001"
    end

    test "parses processing_id as PT struct" do
      result = MSH.parse(@raw_msh)

      assert %HL7v2.Type.PT{processing_id: "P", processing_mode: nil} = result.processing_id
    end

    test "parses version_id as VID struct" do
      result = MSH.parse(@raw_msh)

      assert %HL7v2.Type.VID{version_id: "2.5.1"} = result.version_id
    end

    test "empty/nil fields beyond provided raw list are nil" do
      result = MSH.parse(@raw_msh)

      assert result.receiving_application == nil
      assert result.receiving_facility == nil
      assert result.security == nil
      assert result.sequence_number == nil
      assert result.continuation_pointer == nil
      assert result.accept_acknowledgment_type == nil
      assert result.application_acknowledgment_type == nil
      assert result.country_code == nil
      assert result.character_set == nil
      assert result.principal_language_of_message == nil
      assert result.alternate_character_set_handling_scheme == nil
      assert result.message_profile_identifier == nil
    end
  end

  describe "encode/1" do
    @raw_msh [
      "|",
      "^~\\&",
      ["SEND", "", ""],
      ["FAC", "", ""],
      "",
      "",
      ["20260322120000"],
      "",
      ["ADT", "A01", "ADT_A01"],
      "MSG001",
      ["P"],
      ["2.5.1"]
    ]

    test "round-trip produces equivalent field list" do
      encoded = @raw_msh |> MSH.parse() |> MSH.encode()

      # MSH-1: field separator
      assert Enum.at(encoded, 0) == "|"
      # MSH-2: encoding characters
      assert Enum.at(encoded, 1) == "^~\\&"
      # MSH-3: sending application (HD)
      assert Enum.at(encoded, 2) == ["SEND"]
      # MSH-4: sending facility (HD)
      assert Enum.at(encoded, 3) == ["FAC"]
      # MSH-7: date/time of message (TS) — index 6
      assert Enum.at(encoded, 6) == ["20260322120000"]
      # MSH-9: message type (MSG) — index 8
      assert Enum.at(encoded, 8) == ["ADT", "A01", "ADT_A01"]
      # MSH-10: message control id — index 9
      assert Enum.at(encoded, 9) == "MSG001"
      # MSH-11: processing id (PT) — index 10
      assert Enum.at(encoded, 10) == ["P"]
      # MSH-12: version id (VID) — index 11
      assert Enum.at(encoded, 11) == ["2.5.1"]
    end

    test "field_separator and encoding_characters are first two elements" do
      msh = %MSH{
        field_separator: "|",
        encoding_characters: "^~\\&",
        message_control_id: "TEST001",
        processing_id: %HL7v2.Type.PT{processing_id: "P"},
        version_id: %HL7v2.Type.VID{version_id: "2.5.1"}
      }

      encoded = MSH.encode(msh)

      assert hd(encoded) == "|"
      assert Enum.at(encoded, 1) == "^~\\&"
    end

    test "trailing nil fields trimmed" do
      msh = %MSH{
        field_separator: "|",
        encoding_characters: "^~\\&",
        message_type: %HL7v2.Type.MSG{message_code: "ACK"}
      }

      encoded = MSH.encode(msh)

      # Should trim everything after message_type
      last = List.last(encoded)
      assert last == ["ACK"]
    end

    test "encodes minimal MSH (only separators)" do
      msh = %MSH{field_separator: "|", encoding_characters: "^~\\&"}

      encoded = MSH.encode(msh)

      assert encoded == ["|", "^~\\&"]
    end
  end
end
