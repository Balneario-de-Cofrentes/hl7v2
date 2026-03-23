defmodule HL7v2.Segment.TXATest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.TXA

  describe "fields/0" do
    test "returns 23 field definitions" do
      assert length(TXA.fields()) == 23
    end
  end

  describe "segment_id/0" do
    test "returns TXA" do
      assert TXA.segment_id() == "TXA"
    end
  end

  describe "parse/1" do
    test "parses set_id and document_type" do
      raw = ["1", "HP"]

      result = TXA.parse(raw)

      assert %TXA{} = result
      assert result.set_id == 1
      assert result.document_type == "HP"
    end

    test "parses document_content_presentation" do
      raw = ["1", "HP", "FT"]

      result = TXA.parse(raw)

      assert result.document_content_presentation == "FT"
    end

    test "parses activity_date_time as TS" do
      raw = ["1", "HP", "", ["20260322120000"]]

      result = TXA.parse(raw)

      assert %HL7v2.Type.TS{
               time: %HL7v2.Type.DTM{
                 year: 2026,
                 month: 3,
                 day: 22,
                 hour: 12,
                 minute: 0,
                 second: 0
               }
             } = result.activity_date_time
    end

    test "parses primary_activity_provider_code as repeating XCN" do
      raw = ["1", "HP", "", "", [["SMITH", "JOHN"]]]

      result = TXA.parse(raw)

      assert [%HL7v2.Type.XCN{id_number: "SMITH"}] = result.primary_activity_provider_code
    end

    test "parses origination and transcription date_time" do
      raw = ["1", "HP", "", "", "", ["20260320100000"], ["20260321140000"]]

      result = TXA.parse(raw)

      assert %HL7v2.Type.TS{time: %HL7v2.Type.DTM{day: 20}} = result.origination_date_time
      assert %HL7v2.Type.TS{time: %HL7v2.Type.DTM{day: 21}} = result.transcription_date_time
    end

    test "parses edit_date_time as repeating TS" do
      raw = ["1", "HP", "", "", "", "", "", [["20260320"], ["20260321"]]]

      result = TXA.parse(raw)

      assert [%HL7v2.Type.TS{}, %HL7v2.Type.TS{}] = result.edit_date_time
    end

    test "parses unique_document_number as EI" do
      raw = Enum.concat(List.duplicate("", 11), [["DOC123", "NS", "2.16.840", "ISO"]])

      result = TXA.parse(raw)

      assert %HL7v2.Type.EI{
               entity_identifier: "DOC123",
               namespace_id: "NS",
               universal_id: "2.16.840",
               universal_id_type: "ISO"
             } = result.unique_document_number
    end

    test "parses parent_document_number as EI" do
      raw = Enum.concat(List.duplicate("", 12), [["PARENT1", "NS"]])

      result = TXA.parse(raw)

      assert %HL7v2.Type.EI{entity_identifier: "PARENT1"} = result.parent_document_number
    end

    test "parses placer_order_number as repeating EI" do
      raw = Enum.concat(List.duplicate("", 13), [[["ORD1", "NS1"], ["ORD2", "NS2"]]])

      result = TXA.parse(raw)

      assert [
               %HL7v2.Type.EI{entity_identifier: "ORD1"},
               %HL7v2.Type.EI{entity_identifier: "ORD2"}
             ] = result.placer_order_number
    end

    test "parses document status fields" do
      raw =
        Enum.concat(List.duplicate("", 16), [
          "AU",
          "R",
          "AV",
          "AC",
          "Change for corrections"
        ])

      result = TXA.parse(raw)

      assert result.document_completion_status == "AU"
      assert result.document_confidentiality_status == "R"
      assert result.document_availability_status == "AV"
      assert result.document_storage_status == "AC"
      assert result.document_change_reason == "Change for corrections"
    end

    test "parses unique_document_file_name" do
      raw = Enum.concat(List.duplicate("", 15), ["report_final.pdf"])

      result = TXA.parse(raw)

      assert result.unique_document_file_name == "report_final.pdf"
    end

    test "parses authentication_person_time_stamp as repeating XCN" do
      raw = Enum.concat(List.duplicate("", 21), [[["AUTH1", "Smith"]]])

      result = TXA.parse(raw)

      assert [%HL7v2.Type.XCN{id_number: "AUTH1"}] = result.authentication_person_time_stamp
    end

    test "parses distributed_copies as repeating XCN" do
      raw = Enum.concat(List.duplicate("", 22), [[["COPY1", "Jones"]]])

      result = TXA.parse(raw)

      assert [%HL7v2.Type.XCN{id_number: "COPY1"}] = result.distributed_copies
    end

    test "parses empty list -- all fields nil" do
      result = TXA.parse([])

      assert %TXA{} = result
      assert result.set_id == nil
      assert result.document_type == nil
      assert result.unique_document_number == nil
      assert result.document_completion_status == nil
    end
  end

  describe "encode/1" do
    test "round-trip: parse then encode" do
      raw = ["1", "HP", "FT", ["20260322120000"]]

      encoded = raw |> TXA.parse() |> TXA.encode()

      assert Enum.at(encoded, 0) == "1"
      assert Enum.at(encoded, 1) == "HP"
      assert Enum.at(encoded, 2) == "FT"
      assert Enum.at(encoded, 3) == ["20260322120000"]
    end

    test "round-trip with unique_document_number" do
      raw = Enum.concat(List.duplicate("", 11), [["DOC123", "NS", "2.16.840", "ISO"]])

      encoded = raw |> TXA.parse() |> TXA.encode()

      assert List.last(encoded) == ["DOC123", "NS", "2.16.840", "ISO"]
    end

    test "round-trip with document status fields" do
      raw =
        Enum.concat(List.duplicate("", 16), [
          "AU",
          "R",
          "AV",
          "AC"
        ])

      encoded = raw |> TXA.parse() |> TXA.encode()

      assert Enum.at(encoded, 16) == "AU"
      assert Enum.at(encoded, 17) == "R"
      assert Enum.at(encoded, 18) == "AV"
      assert Enum.at(encoded, 19) == "AC"
    end

    test "trailing nil fields trimmed" do
      txa = %TXA{set_id: 1, document_type: "HP"}

      encoded = TXA.encode(txa)

      assert encoded == ["1", "HP"]
    end

    test "encodes all-nil struct to empty list" do
      assert TXA.encode(%TXA{}) == []
    end
  end

  describe "typed parsing integration" do
    test "MDM^T02 with TXA parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||MDM^T02|1|P|2.5.1\r" <>
          "EVN|T02|20260322\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|I\r" <>
          "TXA|1|HP||20260322120000||||||||DOC123^NS\r" <>
          "OBX|1|TX|1234^Report||Final report text\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      txa = Enum.find(msg.segments, &is_struct(&1, TXA))
      assert %TXA{} = txa
      assert txa.set_id == 1
      assert txa.document_type == "HP"
      assert %HL7v2.Type.EI{entity_identifier: "DOC123"} = txa.unique_document_number
    end
  end
end
