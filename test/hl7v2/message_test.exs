defmodule HL7v2.MessageTest do
  use ExUnit.Case, async: true

  alias HL7v2.Message
  alias HL7v2.Segment.{PID, PV1, OBR, OBX, NTE}
  alias HL7v2.Type.{HD, MSG, PT, VID, TS, DTM, CX, XPN, FN}

  describe "new/3" do
    test "creates message with correct message type" do
      msg = Message.new("ADT", "A01")

      assert %MSG{message_code: "ADT", trigger_event: "A01", message_structure: "ADT_A01"} =
               msg.msh.message_type
    end

    test "sets default field separator and encoding characters" do
      msg = Message.new("ADT", "A01")

      assert msg.msh.field_separator == "|"
      assert msg.msh.encoding_characters == "^~\\&"
    end

    test "sets default processing ID and version" do
      msg = Message.new("ADT", "A01")

      assert %PT{processing_id: "P"} = msg.msh.processing_id
      assert %VID{version_id: "2.5.1"} = msg.msh.version_id
    end

    test "auto-generates message control ID" do
      msg = Message.new("ADT", "A01")

      assert is_binary(msg.msh.message_control_id)
      assert String.length(msg.msh.message_control_id) > 0
    end

    test "auto-generates date/time of message" do
      msg = Message.new("ADT", "A01")

      assert %TS{time: %DTM{year: year}} = msg.msh.date_time_of_message
      assert year >= 2026
    end

    test "accepts sending/receiving application as strings" do
      msg = Message.new("ADT", "A01", sending_application: "PHAOS", receiving_application: "RCV")

      assert %HD{namespace_id: "PHAOS"} = msg.msh.sending_application
      assert %HD{namespace_id: "RCV"} = msg.msh.receiving_application
    end

    test "accepts sending/receiving as HD structs" do
      hd = %HD{namespace_id: "APP", universal_id: "1.2.3", universal_id_type: "ISO"}
      msg = Message.new("ADT", "A01", sending_application: hd)

      assert msg.msh.sending_application == hd
    end

    test "accepts custom options" do
      msg =
        Message.new("ORU", "R01",
          sending_facility: "HOSP",
          message_control_id: "CUSTOM123",
          processing_id: "D",
          version_id: "2.3"
        )

      assert %HD{namespace_id: "HOSP"} = msg.msh.sending_facility
      assert msg.msh.message_control_id == "CUSTOM123"
      assert %PT{processing_id: "D"} = msg.msh.processing_id
      assert %VID{version_id: "2.3"} = msg.msh.version_id
    end

    test "starts with empty segments list" do
      msg = Message.new("ADT", "A01")
      assert msg.segments == []
    end

    test "uses canonical structure for shared-structure events" do
      # ADT^A08 uses ADT_A01 structure, NOT ADT_A08
      msg = Message.new("ADT", "A08")
      assert msg.msh.message_type.message_structure == "ADT_A01"

      # ADT^A31 uses ADT_A05
      msg = Message.new("ADT", "A31")
      assert msg.msh.message_type.message_structure == "ADT_A05"

      # ADT^A40 uses ADT_A39
      msg = Message.new("ADT", "A40")
      assert msg.msh.message_type.message_structure == "ADT_A39"

      # SIU^S14 uses SIU_S12
      msg = Message.new("SIU", "S14")
      assert msg.msh.message_type.message_structure == "SIU_S12"

      # ADT^A01 is its own canonical (no mapping needed)
      msg = Message.new("ADT", "A01")
      assert msg.msh.message_type.message_structure == "ADT_A01"

      # Unknown events fall back to CODE_EVENT
      msg = Message.new("ZZZ", "Z01")
      assert msg.msh.message_type.message_structure == "ZZZ_Z01"
    end
  end

  describe "add_segment/2" do
    test "appends a segment" do
      msg =
        Message.new("ADT", "A01")
        |> Message.add_segment(%PID{set_id: 1})

      assert length(msg.segments) == 1
      assert %PID{set_id: 1} = hd(msg.segments)
    end

    test "preserves order" do
      msg =
        Message.new("ADT", "A01")
        |> Message.add_segment(%PID{set_id: 1})
        |> Message.add_segment(%PV1{patient_class: "I"})
        |> Message.add_segment(%NTE{set_id: 1})

      assert [%PID{}, %PV1{}, %NTE{}] = msg.segments
    end

    test "allows multiple segments of same type" do
      msg =
        Message.new("ORU", "R01")
        |> Message.add_segment(%OBX{set_id: 1, observation_result_status: "F"})
        |> Message.add_segment(%OBX{set_id: 2, observation_result_status: "F"})

      assert length(msg.segments) == 2
    end
  end

  describe "segments/2" do
    test "filters by type" do
      msg =
        Message.new("ORU", "R01")
        |> Message.add_segment(%OBR{set_id: 1})
        |> Message.add_segment(%OBX{set_id: 1, observation_result_status: "F"})
        |> Message.add_segment(%OBX{set_id: 2, observation_result_status: "F"})
        |> Message.add_segment(%NTE{set_id: 1})

      obxs = Message.segments(msg, OBX)
      assert length(obxs) == 2
      assert Enum.all?(obxs, &is_struct(&1, OBX))
    end

    test "returns empty list when no matches" do
      msg = Message.new("ADT", "A01")
      assert Message.segments(msg, PID) == []
    end
  end

  describe "segment/2" do
    test "returns first match" do
      msg =
        Message.new("ORU", "R01")
        |> Message.add_segment(%OBX{set_id: 1, observation_result_status: "F"})
        |> Message.add_segment(%OBX{set_id: 2, observation_result_status: "P"})

      assert %OBX{set_id: 1} = Message.segment(msg, OBX)
    end

    test "returns nil when no match" do
      msg = Message.new("ADT", "A01")
      assert Message.segment(msg, PID) == nil
    end
  end

  describe "encode/1" do
    test "produces valid wire format" do
      msg =
        Message.new("ADT", "A01",
          sending_application: "SEND",
          message_control_id: "MSG001"
        )

      wire = Message.encode(msg)

      assert String.starts_with?(wire, "MSH|^~\\&|SEND")
      assert String.ends_with?(wire, "\r")
      assert wire =~ "ADT^A01^ADT_A01"
      assert wire =~ "MSG001"
    end

    test "includes all segments in order" do
      msg =
        Message.new("ADT", "A01",
          sending_application: "SEND",
          message_control_id: "CTL001"
        )
        |> Message.add_segment(%PID{
          set_id: 1,
          patient_identifier_list: [%CX{id: "12345", identifier_type_code: "MR"}],
          patient_name: [%XPN{family_name: %FN{surname: "Smith"}, given_name: "John"}],
          administrative_sex: "M"
        })
        |> Message.add_segment(%PV1{patient_class: "I"})

      wire = Message.encode(msg)
      segments = String.split(wire, "\r", trim: true)

      assert length(segments) == 3
      assert String.starts_with?(Enum.at(segments, 0), "MSH|")
      assert String.starts_with?(Enum.at(segments, 1), "PID|")
      assert String.starts_with?(Enum.at(segments, 2), "PV1|")
    end

    test "round-trip: encode → parse → verify" do
      msg =
        Message.new("ADT", "A01",
          sending_application: "SEND",
          sending_facility: "FAC",
          receiving_application: "RCV",
          message_control_id: "RT001"
        )
        |> Message.add_segment(%PID{
          set_id: 1,
          patient_identifier_list: [%CX{id: "MRN123", identifier_type_code: "MR"}],
          patient_name: [%XPN{family_name: %FN{surname: "Doe"}, given_name: "Jane"}]
        })

      wire = Message.encode(msg)
      {:ok, parsed} = HL7v2.parse(wire)

      assert parsed.type == {"ADT", "A01", "ADT_A01"}
      assert length(parsed.segments) == 2
    end
  end

  describe "builder validates with canonical structure definitions" do
    test "ADT^A28 (add person) validates without warnings via ADT_A05" do
      msg =
        Message.new("ADT", "A28", message_control_id: "A28_001")
        |> Message.add_segment(%HL7v2.Segment.EVN{
          recorded_date_time: %TS{time: %DTM{year: 2026, month: 3, day: 22}}
        })
        |> Message.add_segment(%PID{
          patient_identifier_list: [%CX{id: "MRN999"}],
          patient_name: [%XPN{family_name: %FN{surname: "Garcia"}, given_name: "Maria"}]
        })
        |> Message.add_segment(%PV1{patient_class: "O"})

      assert msg.msh.message_type.message_structure == "ADT_A05"

      wire = Message.encode(msg)
      {:ok, parsed} = HL7v2.parse(wire)
      {:ok, typed} = HL7v2.type(parsed)
      assert :ok = HL7v2.Validation.validate(typed)
    end

    test "ADT^A40 (merge patient) validates via ADT_A39 and detects missing MRG" do
      msg =
        Message.new("ADT", "A40", message_control_id: "A40_001")
        |> Message.add_segment(%HL7v2.Segment.EVN{
          recorded_date_time: %TS{time: %DTM{year: 2026, month: 3, day: 22}}
        })
        |> Message.add_segment(%PID{
          patient_identifier_list: [%CX{id: "MRN123"}],
          patient_name: [%XPN{family_name: %FN{surname: "Doe"}}]
        })

      assert msg.msh.message_type.message_structure == "ADT_A39"

      wire = Message.encode(msg)
      {:ok, parsed} = HL7v2.parse(wire)
      {:ok, typed} = HL7v2.type(parsed)
      assert {:error, errors} = HL7v2.Validation.validate(typed)
      assert Enum.any?(errors, &(&1.message == "Required segment MRG is missing"))
    end

    test "ADT^A11 (cancel admit) validates via ADT_A09" do
      msg =
        Message.new("ADT", "A11", message_control_id: "A11_001")
        |> Message.add_segment(%HL7v2.Segment.EVN{
          recorded_date_time: %TS{time: %DTM{year: 2026, month: 3, day: 22}}
        })
        |> Message.add_segment(%PID{
          patient_identifier_list: [%CX{id: "MRN555"}],
          patient_name: [%XPN{family_name: %FN{surname: "Lopez"}}]
        })
        |> Message.add_segment(%PV1{patient_class: "I"})

      assert msg.msh.message_type.message_structure == "ADT_A09"

      wire = Message.encode(msg)
      {:ok, parsed} = HL7v2.parse(wire)
      {:ok, typed} = HL7v2.type(parsed)
      assert :ok = HL7v2.Validation.validate(typed)
    end
  end

  describe "to_raw/1" do
    test "produces valid RawMessage" do
      msg = Message.new("ACK", "A01", message_control_id: "RAW001")
      raw = Message.to_raw(msg)

      assert %HL7v2.RawMessage{} = raw
      assert raw.type == {"ACK", "A01", "ACK_A01"}
      assert length(raw.segments) == 1
      assert {"MSH", _fields} = hd(raw.segments)
    end
  end
end
