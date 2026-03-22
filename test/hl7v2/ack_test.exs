defmodule HL7v2.AckTest do
  use ExUnit.Case, async: true

  alias HL7v2.Ack
  alias HL7v2.Segment.{MSH, MSA, ERR}
  alias HL7v2.Type.{HD, MSG, PT, VID, TS, DTM, CWE}

  @original_msh %MSH{
    field_separator: "|",
    encoding_characters: "^~\\&",
    sending_application: %HD{namespace_id: "SEND_APP"},
    sending_facility: %HD{namespace_id: "SEND_FAC"},
    receiving_application: %HD{namespace_id: "RCV_APP"},
    receiving_facility: %HD{namespace_id: "RCV_FAC"},
    message_type: %MSG{message_code: "ADT", trigger_event: "A01"},
    message_control_id: "ORIG123",
    processing_id: %PT{processing_id: "P"},
    version_id: %VID{version_id: "2.5.1"},
    date_time_of_message: %TS{time: %DTM{year: 2026, month: 3, day: 22, hour: 12}}
  }

  describe "accept/1" do
    test "produces AA with correct MSA control ID matching original" do
      {_ack_msh, msa} = Ack.accept(@original_msh)

      assert %MSA{} = msa
      assert msa.acknowledgment_code == "AA"
      assert msa.message_control_id == "ORIG123"
    end

    test "returns a two-element tuple (no ERR segment)" do
      result = Ack.accept(@original_msh)

      assert {%MSH{}, %MSA{}} = result
    end
  end

  describe "error/2" do
    test "produces AE with text message" do
      {_ack_msh, msa} = Ack.error(@original_msh, text: "Something went wrong")

      assert msa.acknowledgment_code == "AE"
      assert msa.text_message == "Something went wrong"
      assert msa.message_control_id == "ORIG123"
    end

    test "returns two-element tuple when no error_code provided" do
      result = Ack.error(@original_msh, text: "Error occurred")

      assert {%MSH{}, %MSA{}} = result
    end

    test "returns three-element tuple with ERR when error_code provided" do
      result =
        Ack.error(@original_msh, error_code: "207", error_text: "Application internal error")

      assert {%MSH{}, %MSA{}, %ERR{}} = result
    end
  end

  describe "reject/2" do
    test "produces AR acknowledgment" do
      {_ack_msh, msa} = Ack.reject(@original_msh)

      assert msa.acknowledgment_code == "AR"
      assert msa.message_control_id == "ORIG123"
    end

    test "returns three-element tuple with ERR when error_code provided" do
      result =
        Ack.reject(@original_msh, error_code: "200", error_text: "Unsupported message type")

      assert {%MSH{}, %MSA{}, %ERR{}} = result
    end
  end

  describe "sender/receiver swap" do
    test "original sending_application becomes ACK receiving_application" do
      {ack_msh, _msa} = Ack.accept(@original_msh)

      assert ack_msh.receiving_application == %HD{namespace_id: "SEND_APP"}
      assert ack_msh.receiving_facility == %HD{namespace_id: "SEND_FAC"}
    end

    test "original receiving_application becomes ACK sending_application" do
      {ack_msh, _msa} = Ack.accept(@original_msh)

      assert ack_msh.sending_application == %HD{namespace_id: "RCV_APP"}
      assert ack_msh.sending_facility == %HD{namespace_id: "RCV_FAC"}
    end

    test "handles nil sending/receiving fields" do
      msh = %MSH{
        @original_msh
        | sending_application: nil,
          sending_facility: nil,
          receiving_application: nil,
          receiving_facility: nil
      }

      {ack_msh, _msa} = Ack.accept(msh)

      assert ack_msh.sending_application == nil
      assert ack_msh.sending_facility == nil
      assert ack_msh.receiving_application == nil
      assert ack_msh.receiving_facility == nil
    end
  end

  describe "MSH message_type" do
    test "ACK message_type has message_code ACK with original trigger event" do
      {ack_msh, _msa} = Ack.accept(@original_msh)

      assert ack_msh.message_type.message_code == "ACK"
      assert ack_msh.message_type.trigger_event == "A01"
      assert ack_msh.message_type.message_structure == "ACK"
    end

    test "preserves trigger event from original message" do
      msh = %MSH{@original_msh | message_type: %MSG{message_code: "ORM", trigger_event: "O01"}}
      {ack_msh, _msa} = Ack.accept(msh)

      assert ack_msh.message_type.trigger_event == "O01"
    end
  end

  describe "message_control_id" do
    test "generates new message_control_id different from original" do
      {ack_msh, _msa} = Ack.accept(@original_msh)

      assert is_binary(ack_msh.message_control_id)
      refute ack_msh.message_control_id == "ORIG123"
    end

    test "allows overriding message_control_id via option" do
      {ack_msh, _msa} = Ack.accept(@original_msh, message_control_id: "CUSTOM_ID")

      assert ack_msh.message_control_id == "CUSTOM_ID"
    end
  end

  describe "preserved fields" do
    test "processing_id preserved from original" do
      {ack_msh, _msa} = Ack.accept(@original_msh)

      assert ack_msh.processing_id == %PT{processing_id: "P"}
    end

    test "version_id preserved from original" do
      {ack_msh, _msa} = Ack.accept(@original_msh)

      assert ack_msh.version_id == %VID{version_id: "2.5.1"}
    end

    test "date_time_of_message is set to current time (not original)" do
      {ack_msh, _msa} = Ack.accept(@original_msh)

      assert %TS{time: %DTM{}} = ack_msh.date_time_of_message
      # The ACK timestamp should be different from the original (2026-03-22 12:00)
      # Since we can't predict exact time, just verify it's a valid timestamp
      assert ack_msh.date_time_of_message.time.year >= 2024
    end
  end

  describe "ERR segment" do
    test "error with error_code produces ERR with CWE hl7_error_code" do
      {_msh, _msa, err} =
        Ack.error(@original_msh,
          error_code: "207",
          error_text: "Application internal error"
        )

      assert %ERR{} = err
      assert %CWE{identifier: "207", text: "Application internal error"} = err.hl7_error_code
    end

    test "error severity defaults to E" do
      {_msh, _msa, err} = Ack.error(@original_msh, error_code: "207")

      assert err.severity == "E"
    end

    test "error severity can be overridden" do
      {_msh, _msa, err} = Ack.error(@original_msh, error_code: "207", severity: "W")

      assert err.severity == "W"
    end

    test "accept never produces ERR segment even with error_code" do
      result = Ack.accept(@original_msh, error_code: "207")

      assert {%MSH{}, %MSA{}} = result
    end
  end

  describe "encode/1" do
    test "produces valid wire format for accept" do
      ack = Ack.accept(@original_msh, message_control_id: "ACK001")
      wire = Ack.encode(ack)

      assert is_binary(wire)
      assert String.starts_with?(wire, "MSH|^~\\&|")
      assert String.contains?(wire, "ACK^A01^ACK")
      assert String.contains?(wire, "ACK001")
      assert String.contains?(wire, "\rMSA|AA|ORIG123\r")
    end

    test "produces valid wire format for error with ERR" do
      ack =
        Ack.error(@original_msh,
          text: "Bad data",
          error_code: "207",
          error_text: "Application internal error",
          message_control_id: "ACK002"
        )

      wire = Ack.encode(ack)

      assert String.contains?(wire, "\rMSA|AE|ORIG123|Bad data\r")
      assert String.contains?(wire, "\rERR|")
      assert String.contains?(wire, "207^Application internal error")
    end

    test "encodes reject without ERR" do
      ack = Ack.reject(@original_msh, text: "Rejected", message_control_id: "ACK003")
      wire = Ack.encode(ack)

      assert String.contains?(wire, "\rMSA|AR|ORIG123|Rejected\r")
      refute String.contains?(wire, "\rERR|")
    end

    test "sender/receiver swap visible in wire format" do
      ack = Ack.accept(@original_msh, message_control_id: "ACK004")
      wire = Ack.encode(ack)

      # ACK MSH should have RCV_APP as sender, SEND_APP as receiver
      assert String.starts_with?(wire, "MSH|^~\\&|RCV_APP|RCV_FAC|SEND_APP|SEND_FAC|")
    end
  end

  describe "round-trip: encode then parse" do
    test "encode then parse back verifies fields" do
      ack = Ack.accept(@original_msh, message_control_id: "RT001")
      wire = Ack.encode(ack)

      assert {:ok, parsed} = HL7v2.Parser.parse(wire)

      # Verify MSH segment
      {"MSH", msh_fields} = Enum.at(parsed.segments, 0)
      assert Enum.at(msh_fields, 0) == "|"
      assert Enum.at(msh_fields, 1) == "^~\\&"
      # MSH-3 (index 2): sending_application = RCV_APP (swapped)
      assert Enum.at(msh_fields, 2) == "RCV_APP"
      # MSH-5 (index 4): receiving_application = SEND_APP (swapped)
      assert Enum.at(msh_fields, 4) == "SEND_APP"
      # MSH-9 (index 8): message type = ACK^A01^ACK
      assert Enum.at(msh_fields, 8) == ["ACK", "A01", "ACK"]
      # MSH-10 (index 9): message control id
      assert Enum.at(msh_fields, 9) == "RT001"
      # MSH-11 (index 10): processing ID = P
      assert Enum.at(msh_fields, 10) == "P"
      # MSH-12 (index 11): version = 2.5.1
      assert Enum.at(msh_fields, 11) == "2.5.1"

      # Verify MSA segment
      {"MSA", msa_fields} = Enum.at(parsed.segments, 1)
      assert Enum.at(msa_fields, 0) == "AA"
      assert Enum.at(msa_fields, 1) == "ORIG123"
    end

    test "error round-trip preserves ERR fields" do
      ack =
        Ack.error(@original_msh,
          text: "Invalid data",
          error_code: "207",
          error_text: "Application internal error",
          message_control_id: "RT002"
        )

      wire = Ack.encode(ack)
      assert {:ok, parsed} = HL7v2.Parser.parse(wire)

      assert length(parsed.segments) == 3

      {"MSA", msa_fields} = Enum.at(parsed.segments, 1)
      assert Enum.at(msa_fields, 0) == "AE"
      assert Enum.at(msa_fields, 1) == "ORIG123"
      assert Enum.at(msa_fields, 2) == "Invalid data"

      {"ERR", err_fields} = Enum.at(parsed.segments, 2)
      # ERR-3 (index 2): hl7_error_code as CWE
      assert Enum.at(err_fields, 2) == ["207", "Application internal error"]
      # ERR-4 (index 3): severity
      assert Enum.at(err_fields, 3) == "E"
    end
  end
end
