defmodule HL7v2Test do
  use ExUnit.Case, async: true

  describe "parse/1" do
    test "delegates to Parser for raw mode" do
      msg = "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\r"
      assert {:ok, raw} = HL7v2.parse(msg)
      assert raw.type == {"ADT", "A01"}
    end

    test "returns error for empty input" do
      assert {:error, :empty_message} = HL7v2.parse("")
    end
  end

  describe "encode/1" do
    test "encodes RawMessage" do
      msg = "MSH|^~\\&|SEND|FAC||RCV|20240101||ADT^A01|123|P|2.5\r"
      {:ok, raw} = HL7v2.Parser.parse(msg)
      assert HL7v2.encode(raw) == msg
    end

    test "encodes Message struct" do
      msg =
        HL7v2.Message.new("ADT", "A01",
          sending_application: "PHAOS",
          message_control_id: "ENC001"
        )

      wire = HL7v2.encode(msg)
      assert String.starts_with?(wire, "MSH|^~\\&|PHAOS|")
      assert wire =~ "ADT^A01^ADT_A01"
      assert wire =~ "ENC001"
      assert String.ends_with?(wire, "\r")
    end

    test "encodes TypedMessage" do
      msg = "MSH|^~\\&|SEND|FAC||RCV|20240101||ADT^A01|456|P|2.5\r"
      {:ok, typed} = HL7v2.Parser.parse(msg, mode: :typed)

      wire = HL7v2.encode(typed)
      assert wire == msg
    end
  end

  describe "new/3" do
    test "delegates to Message.new/3" do
      msg = HL7v2.new("ADT", "A01", sending_application: "PHAOS")
      assert %HL7v2.Message{} = msg
      assert msg.msh.sending_application.namespace_id == "PHAOS"
    end

    test "works with no options" do
      msg = HL7v2.new("ORU", "R01")
      assert %HL7v2.Message{} = msg
      assert msg.msh.message_type.message_code == "ORU"
      assert msg.msh.message_type.trigger_event == "R01"
    end
  end

  describe "ack/2" do
    test "builds an AA acknowledgment" do
      msh = %HL7v2.Segment.MSH{
        field_separator: "|",
        encoding_characters: "^~\\&",
        sending_application: %HL7v2.Type.HD{namespace_id: "SENDER"},
        receiving_application: %HL7v2.Type.HD{namespace_id: "RECEIVER"},
        message_type: %HL7v2.Type.MSG{message_code: "ADT", trigger_event: "A01"},
        message_control_id: "CTL001",
        processing_id: %HL7v2.Type.PT{processing_id: "P"},
        version_id: %HL7v2.Type.VID{version_id: "2.5.1"}
      }

      {ack_msh, msa} = HL7v2.ack(msh)

      assert msa.acknowledgment_code == "AA"
      assert msa.message_control_id == "CTL001"
      assert ack_msh.sending_application.namespace_id == "RECEIVER"
      assert ack_msh.receiving_application.namespace_id == "SENDER"
    end
  end

  describe "round-trip integration" do
    test "build → encode → parse → verify (raw)" do
      msg =
        HL7v2.new("ADT", "A01",
          sending_application: "PHAOS",
          sending_facility: "HOSP",
          message_control_id: "INT001"
        )
        |> HL7v2.Message.add_segment(%HL7v2.Segment.PID{
          set_id: 1,
          patient_identifier_list: [%HL7v2.Type.CX{id: "12345"}],
          patient_name: [
            %HL7v2.Type.XPN{
              family_name: %HL7v2.Type.FN{surname: "Smith"},
              given_name: "John"
            }
          ]
        })

      wire = HL7v2.encode(msg)

      # Parse back as raw
      {:ok, raw} = HL7v2.parse(wire)
      assert %HL7v2.RawMessage{} = raw
      assert {code, event, _structure} = raw.type
      assert code == "ADT"
      assert event == "A01"

      # Should have MSH + PID
      assert length(raw.segments) == 2
      assert {"MSH", _} = Enum.at(raw.segments, 0)
      assert {"PID", _} = Enum.at(raw.segments, 1)
    end

    test "build → encode → parse as typed → verify fields" do
      msg =
        HL7v2.new("ADT", "A01",
          sending_application: "PHAOS",
          sending_facility: "HOSP",
          message_control_id: "INT002"
        )
        |> HL7v2.Message.add_segment(%HL7v2.Segment.PID{
          set_id: 1,
          patient_identifier_list: [%HL7v2.Type.CX{id: "12345"}],
          patient_name: [
            %HL7v2.Type.XPN{
              family_name: %HL7v2.Type.FN{surname: "Smith"},
              given_name: "John"
            }
          ]
        })

      wire = HL7v2.encode(msg)

      {:ok, typed} = HL7v2.parse(wire, mode: :typed)
      assert %HL7v2.TypedMessage{} = typed

      # MSH
      msh = hd(typed.segments)
      assert %HL7v2.Segment.MSH{} = msh
      assert msh.sending_application.namespace_id == "PHAOS"
      assert msh.sending_facility.namespace_id == "HOSP"
      assert msh.message_control_id == "INT002"
      assert msh.message_type.message_code == "ADT"
      assert msh.message_type.trigger_event == "A01"

      # PID
      pid = Enum.at(typed.segments, 1)
      assert %HL7v2.Segment.PID{} = pid
      assert pid.set_id == 1
      assert [%HL7v2.Type.CX{id: "12345"}] = pid.patient_identifier_list
      assert [%HL7v2.Type.XPN{given_name: "John"} = xpn] = pid.patient_name
      assert xpn.family_name.surname == "Smith"
    end

    test "typed round-trip preserves wire format" do
      wire = "MSH|^~\\&|SEND|FAC||RCV|20240101||ADT^A01|789|P|2.5\r"

      {:ok, typed} = HL7v2.parse(wire, mode: :typed)
      re_encoded = HL7v2.encode(typed)

      assert re_encoded == wire
    end

    test "encode → parse → encode idempotent for builder messages" do
      msg =
        HL7v2.new("ORU", "R01",
          sending_application: "LAB",
          message_control_id: "IDEM001"
        )

      wire1 = HL7v2.encode(msg)
      {:ok, raw} = HL7v2.parse(wire1)
      wire2 = HL7v2.encode(raw)

      assert wire1 == wire2
    end
  end

  describe "parse with validate: true" do
    test "returns errors for invalid typed message" do
      # PID missing required patient_identifier_list and patient_name
      wire =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01^ADT_A01|1|P|2.5.1\r" <>
          "EVN|A01|20260322\r" <>
          "PID|1\r" <>
          "PV1|1|I\r"

      assert {:error, errors} = HL7v2.parse(wire, mode: :typed, validate: true)
      assert is_list(errors)
      assert length(errors) > 0

      locations = Enum.map(errors, & &1.field)
      assert :patient_identifier_list in locations or :patient_name in locations
    end

    test "returns ok for valid typed message" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01^ADT_A01|1|P|2.5.1\r" <>
          "EVN|A01|20260322\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|I\r"

      assert {:ok, %HL7v2.TypedMessage{}} = HL7v2.parse(wire, mode: :typed, validate: true)
    end

    test "validate: true is ignored for raw mode" do
      wire = "MSH|^~\\&|S|F||R||20260322||ADT^A01|1|P|2.5\r"
      assert {:ok, %HL7v2.RawMessage{}} = HL7v2.parse(wire, validate: true)
    end
  end
end
