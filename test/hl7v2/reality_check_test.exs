defmodule HL7v2.RealityCheckTest do
  use ExUnit.Case, async: true

  # ── 1. Round-trip fidelity ──────────────────────────────────────────

  describe "raw round-trip fidelity" do
    @real_world_message Enum.join(
                          [
                            "MSH|^~\\&|EPIC|HOSP|LAB|LABFAC|20260322143022.1234+0500||ADT^A01^ADT_A01|MSG00001|P|2.5.1|||AL|NE||UNICODE UTF-8",
                            "EVN|A01|20260322143022",
                            "PID|1||MRN12345^^^HOSP^MR~SSN123456^^^SSA^SS||Smith^John^Q^Jr^Dr^PhD^L^A||19800515|M||2106-3^White^CDCREC|123 Main St^^Springfield^IL^62704^USA^H~456 Oak Ave^^Chicago^IL^60601^USA^W||^PRN^PH^^1^217^5551234|^WPN^PH^^1^312^5555678|EN^English^HL70296|M^Married^HL70002|CHR^Christian^HL70006|ACC12345^^^HOSP^AN||||||||N",
                            "PV1|1|I|W^389^1^HOSP^^N|||12345^Jones^Robert^^^Dr^MD|67890^Smith^Jane|||SUR||||A|||12345^Jones^Robert^^^Dr^MD|IP|VN001^^^HOSP^VN||||||||||||||||||||||||20260322120000",
                            "NTE|1|L|Patient allergic to penicillin",
                            "NTE|2|L|Family history of diabetes",
                            ""
                          ],
                          "\r"
                        )

    test "parse then encode produces byte-identical output" do
      text = @real_world_message

      {:ok, raw} = HL7v2.parse(text)
      wire = HL7v2.Encoder.encode(raw)

      assert wire == text,
             "Round-trip failed.\nExpected #{byte_size(text)} bytes, got #{byte_size(wire)} bytes.\n" <>
               diff_details(text, wire)
    end

    test "simple message round-trips" do
      text = "MSH|^~\\&|SEND|FAC||RCV||20240101||ADT^A01|123|P|2.5\r"
      {:ok, raw} = HL7v2.parse(text)
      wire = HL7v2.Encoder.encode(raw)
      assert wire == text
    end

    test "message with repetitions round-trips" do
      text = "MSH|^~\\&|S|F||R||20240101||ADT^A01|1|P|2.5\rPID|1||ID1^^^AUTH1^MR~ID2^^^AUTH2^SS\r"
      {:ok, raw} = HL7v2.parse(text)
      wire = HL7v2.Encoder.encode(raw)
      assert wire == text
    end

    test "message with sub-components round-trips" do
      text =
        "MSH|^~\\&|S|F||R||20240101||ADT^A01|1|P|2.5\rPID|1||12345^^^AUTH&1.2.3&ISO^MR\r"

      {:ok, raw} = HL7v2.parse(text)
      wire = HL7v2.Encoder.encode(raw)
      assert wire == text
    end

    test "message with empty trailing fields preserves structure" do
      text = "MSH|^~\\&|S|F||R||20240101||ADT^A01|1|P|2.5\rPID|1\r"
      {:ok, raw} = HL7v2.parse(text)
      wire = HL7v2.Encoder.encode(raw)
      assert wire == text
    end

    test "MSH with all 21 fields round-trips" do
      text =
        "MSH|^~\\&|SEND|FAC|RECV|RFAC|20260322143022||ADT^A01^ADT_A01|CTL1|P|2.5.1|123|CONT|AL|NE|USA|UNICODE UTF-8||SIG|PROF^1.2.3\r"

      {:ok, raw} = HL7v2.parse(text)
      wire = HL7v2.Encoder.encode(raw)
      assert wire == text
    end

    test "escape sequences in field data round-trip" do
      # HL7 escape sequences should be preserved verbatim in raw mode
      text =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.5\rNTE|1||Line 1\\.br\\Line 2\r"

      {:ok, raw} = HL7v2.parse(text)
      wire = HL7v2.Encoder.encode(raw)
      assert wire == text
    end

    test "message with many empty middle segments round-trips" do
      text =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.5\rPID\rPV1\rNTE|1\r"

      {:ok, raw} = HL7v2.parse(text)
      wire = HL7v2.Encoder.encode(raw)
      assert wire == text
    end

    test "message with mixed sub-components and repetitions round-trips" do
      # Complex: PID-3 with two reps, each having sub-components in assigning authority
      text =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.5\rPID|1||ID1^^^A&1.2&ISO^MR~ID2^^^B&3.4&DNS^SS\r"

      {:ok, raw} = HL7v2.parse(text)
      wire = HL7v2.Encoder.encode(raw)
      assert wire == text
    end

    test "mixed-structure repetitions: simple ~ composite round-trips" do
      # Regression: a~b^c must NOT become a^b&c
      text =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.5\rPID|1||a~b^c||Smith^John\r"

      {:ok, raw} = HL7v2.parse(text)
      wire = HL7v2.Encoder.encode(raw)
      assert wire == text
    end

    test "simple string repetitions round-trip" do
      # Regression: id1~id2 must NOT become id1^id2
      text =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.5\rPID|1||id1~id2||Smith^John\r"

      {:ok, raw} = HL7v2.parse(text)
      wire = HL7v2.Encoder.encode(raw)
      assert wire == text
    end

    test "three simple repetitions round-trip" do
      text =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.5\rPID|1||a~b~c||Smith^John\r"

      {:ok, raw} = HL7v2.parse(text)
      wire = HL7v2.Encoder.encode(raw)
      assert wire == text
    end

    test "repetition with one simple and two composite values round-trips" do
      text =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.5\rPID|1||simple~a^b~c^d^e\r"

      {:ok, raw} = HL7v2.parse(text)
      wire = HL7v2.Encoder.encode(raw)
      assert wire == text
    end

    test "round-trip with truncation character (v2.7+)" do
      text = "MSH|^~\\&#|SEND|FAC||RCV||20260322||ADT^A01|1|P|2.7\r"
      {:ok, raw} = HL7v2.parse(text)
      assert raw.separators.truncation == ?#
      assert HL7v2.Encoder.encode(raw) == text
    end

    test "round-trip with truncation character and multiple segments" do
      text =
        "MSH|^~\\&#|SEND|FAC||RCV||20260322||ADT^A01|1|P|2.7\rPID|1||12345^^^MRN||Smith^John\r"

      {:ok, raw} = HL7v2.parse(text)
      assert raw.separators.truncation == ?#
      wire = HL7v2.Encoder.encode(raw)
      assert wire == text
    end

    test "round-trip with truncation character and truncated field value" do
      # The # at the end of "Smith#" is a truncated value marker, NOT a delimiter
      text =
        "MSH|^~\\&#|SEND|FAC||RCV||20260322||ADT^A01|1|P|2.7\rPID|1||12345||Smith#^John\r"

      {:ok, raw} = HL7v2.parse(text)
      assert raw.separators.truncation == ?#
      wire = HL7v2.Encoder.encode(raw)
      assert wire == text

      # Verify the truncated value is preserved literally (not split)
      [_, {"PID", pid_fields}] = raw.segments
      assert Enum.at(pid_fields, 4) == ["Smith#", "John"]
    end
  end

  # ── 2. Malformed input handling ─────────────────────────────────────

  describe "malformed input handling" do
    test "empty message returns error" do
      assert {:error, _reason} = HL7v2.parse("")
    end

    test "message without MSH returns error" do
      assert {:error, _reason} = HL7v2.parse("PID|1||12345\r")
    end

    test "MSH with insufficient encoding chars returns error" do
      assert {:error, _reason} = HL7v2.parse("MSH|^\r")
    end

    test "minimal MSH (only encoding chars) parses without crash" do
      result = HL7v2.parse("MSH|^~\\&|\r")
      # Should either succeed or return a descriptive error — never crash
      assert match?({:ok, _}, result) or match?({:error, _}, result)
    end

    test "segment with no fields does not crash" do
      text = "MSH|^~\\&|SEND|||RCV||20260322||ADT^A01|1|P|2.5\rPID\r"
      result = HL7v2.parse(text)
      assert match?({:ok, _}, result) or match?({:error, _}, result)
    end

    test "segment with no fields round-trips" do
      text = "MSH|^~\\&|SEND|||RCV||20260322||ADT^A01|1|P|2.5\rPID\r"
      {:ok, raw} = HL7v2.parse(text)
      wire = HL7v2.Encoder.encode(raw)
      assert wire == text
    end

    test "very long field (>5000 chars) does not crash" do
      long_text = String.duplicate("x", 5000)

      text =
        "MSH|^~\\&|SEND|||RCV||20260322||ADT^A01|1|P|2.5\rNTE|1||#{long_text}\r"

      {:ok, raw} = HL7v2.parse(text)
      wire = HL7v2.Encoder.encode(raw)
      assert wire == text
    end

    test "null field markers (HL7 explicit null) parse without crash" do
      text =
        "MSH|^~\\&|SEND|||RCV||20260322||ADT^A01|1|P|2.5\rPID|1||\"\"||\"\"^\"\"|||\r"

      result = HL7v2.parse(text)
      assert match?({:ok, _}, result)
    end

    test "null field markers round-trip" do
      text =
        "MSH|^~\\&|SEND|||RCV||20260322||ADT^A01|1|P|2.5\rPID|1||\"\"||\"\"^\"\"|||\r"

      {:ok, raw} = HL7v2.parse(text)
      wire = HL7v2.Encoder.encode(raw)
      assert wire == text
    end

    test "message with LF line endings parses" do
      text = "MSH|^~\\&|SEND|||RCV||20260322||ADT^A01|1|P|2.5\nPID|1||12345\n"
      {:ok, raw} = HL7v2.parse(text)
      assert length(raw.segments) == 2
    end

    test "message with CRLF line endings parses" do
      text =
        "MSH|^~\\&|SEND|||RCV||20260322||ADT^A01|1|P|2.5\r\nPID|1||12345\r\n"

      {:ok, raw} = HL7v2.parse(text)
      assert length(raw.segments) == 2
    end

    test "message with no trailing segment terminator parses" do
      text = "MSH|^~\\&|SEND|||RCV||20260322||ADT^A01|1|P|2.5\rPID|1||12345"
      {:ok, raw} = HL7v2.parse(text)
      assert length(raw.segments) == 2
    end

    test "message with no trailing CR round-trips with CR appended" do
      # The encoder always adds a trailing CR, so if input lacked one,
      # the wire output should still be valid HL7 with CR
      text = "MSH|^~\\&|SEND|||RCV||20260322||ADT^A01|1|P|2.5\rPID|1||12345"
      {:ok, raw} = HL7v2.parse(text)
      wire = HL7v2.Encoder.encode(raw)
      # Should be parseable again
      assert {:ok, _} = HL7v2.parse(wire)
    end

    test "MSH only (missing message type) returns error" do
      result = HL7v2.parse("MSH|^~\\&|SEND|FAC\r")
      assert {:error, :missing_message_type} = result
    end
  end

  # ── 3. Typed parse round-trip ───────────────────────────────────────

  describe "typed parse round-trip" do
    test "typed -> raw -> encode produces re-parseable HL7" do
      text =
        "MSH|^~\\&|SEND|FAC||RCV||20260322||ADT^A01|123|P|2.5\rPID|1||12345^^^MRN||Smith^John\r"

      {:ok, typed} = HL7v2.parse(text, mode: :typed)
      raw = HL7v2.TypedParser.to_raw(typed)
      wire = HL7v2.Encoder.encode(raw)

      # Must be re-parseable
      assert {:ok, reparsed} = HL7v2.parse(wire)
      assert length(reparsed.segments) == 2

      # Also re-parseable as typed
      assert {:ok, _typed2} = HL7v2.parse(wire, mode: :typed)
    end

    test "typed -> raw -> encode preserves key MSH fields" do
      text =
        "MSH|^~\\&|SEND|FAC||RCV|20260322||ADT^A01|123|P|2.5\rPID|1||12345^^^MRN||Smith^John\r"

      {:ok, typed} = HL7v2.parse(text, mode: :typed)
      raw = HL7v2.TypedParser.to_raw(typed)
      wire = HL7v2.Encoder.encode(raw)

      {:ok, typed2} = HL7v2.parse(wire, mode: :typed)
      msh = hd(typed2.segments)

      assert msh.sending_application.namespace_id == "SEND"
      assert msh.sending_facility.namespace_id == "FAC"
      assert msh.message_control_id == "123"
      assert msh.message_type.message_code == "ADT"
      assert msh.message_type.trigger_event == "A01"
    end

    test "typed -> raw -> encode preserves PID fields" do
      text =
        "MSH|^~\\&|SEND|FAC||RCV|20260322||ADT^A01|123|P|2.5\rPID|1||12345^^^MRN^MR||Smith^John\r"

      {:ok, typed} = HL7v2.parse(text, mode: :typed)
      raw = HL7v2.TypedParser.to_raw(typed)
      wire = HL7v2.Encoder.encode(raw)

      {:ok, typed2} = HL7v2.parse(wire, mode: :typed)
      pid = Enum.at(typed2.segments, 1)

      assert hd(pid.patient_identifier_list).id == "12345"
      assert hd(pid.patient_identifier_list).assigning_authority.namespace_id == "MRN"
      assert hd(pid.patient_identifier_list).identifier_type_code == "MR"
      assert hd(pid.patient_name).family_name.surname == "Smith"
      assert hd(pid.patient_name).given_name == "John"
    end

    test "typed parse preserves sub-components in CX assigning authority" do
      # CX with sub-components in assigning authority (HD): AUTH&1.2.3&ISO
      text =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.5\rPID|1||12345^^^AUTH&1.2.3&ISO^MR\r"

      {:ok, typed} = HL7v2.parse(text, mode: :typed)
      pid = Enum.at(typed.segments, 1)
      cx = hd(pid.patient_identifier_list)

      assert cx.id == "12345"
      assert cx.identifier_type_code == "MR"
      # The assigning authority sub-components must survive typed parse
      assert cx.assigning_authority != nil
      assert cx.assigning_authority.namespace_id == "AUTH"
      assert cx.assigning_authority.universal_id == "1.2.3"
      assert cx.assigning_authority.universal_id_type == "ISO"
    end

    test "typed parse preserves sub-components with multiple repetitions" do
      text =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.5\rPID|1||ID1^^^AUTH&1.2.3&ISO^MR~ID2^^^OTHER&4.5.6&DNS^SS\r"

      {:ok, typed} = HL7v2.parse(text, mode: :typed)
      pid = Enum.at(typed.segments, 1)

      assert length(pid.patient_identifier_list) == 2

      cx1 = Enum.at(pid.patient_identifier_list, 0)
      assert cx1.id == "ID1"
      assert cx1.assigning_authority.namespace_id == "AUTH"
      assert cx1.assigning_authority.universal_id == "1.2.3"
      assert cx1.assigning_authority.universal_id_type == "ISO"
      assert cx1.identifier_type_code == "MR"

      cx2 = Enum.at(pid.patient_identifier_list, 1)
      assert cx2.id == "ID2"
      assert cx2.assigning_authority.namespace_id == "OTHER"
      assert cx2.assigning_authority.universal_id == "4.5.6"
      assert cx2.assigning_authority.universal_id_type == "DNS"
      assert cx2.identifier_type_code == "SS"
    end

    test "typed parse preserves XPN sub-components (FN with parts)" do
      text =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.5\rPID|1||12345||Smith&Van&Der^John\r"

      {:ok, typed} = HL7v2.parse(text, mode: :typed)
      pid = Enum.at(typed.segments, 1)
      xpn = hd(pid.patient_name)

      assert xpn.family_name != nil
      assert xpn.family_name.surname == "Smith"
      assert xpn.family_name.own_surname_prefix == "Van"
      assert xpn.family_name.own_surname == "Der"
      assert xpn.given_name == "John"
    end

    test "typed parse preserves PL facility sub-components" do
      text =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.5\rPV1|1|I|W^389^1^HOSP&1.2.3&ISO^^N\r"

      {:ok, typed} = HL7v2.parse(text, mode: :typed)
      pv1 = Enum.at(typed.segments, 1)

      assert pv1.assigned_patient_location != nil
      assert pv1.assigned_patient_location.point_of_care == "W"
      assert pv1.assigned_patient_location.room == "389"
      assert pv1.assigned_patient_location.bed == "1"
      assert pv1.assigned_patient_location.facility != nil
      assert pv1.assigned_patient_location.facility.namespace_id == "HOSP"
      assert pv1.assigned_patient_location.facility.universal_id == "1.2.3"
      assert pv1.assigned_patient_location.facility.universal_id_type == "ISO"
      assert pv1.assigned_patient_location.person_location_type == "N"
    end

    test "typed: mixed-structure repetitions produce correct count" do
      # Regression: 12345~67890^^^SS must produce 2 CX values, not 1 garbled one
      text =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.5\rPID|1||12345~67890^^^^SS||Smith^John\r"

      {:ok, typed} = HL7v2.parse(text, mode: :typed)
      pid = Enum.at(typed.segments, 1)

      assert length(pid.patient_identifier_list) == 2
      assert hd(pid.patient_identifier_list).id == "12345"
      assert Enum.at(pid.patient_identifier_list, 1).id == "67890"
      assert Enum.at(pid.patient_identifier_list, 1).identifier_type_code == "SS"
    end

    test "typed: mixed-structure repetitions round-trip through encode" do
      text =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.5\rPID|1||12345~67890^^^^SS||Smith^John\r"

      {:ok, typed} = HL7v2.parse(text, mode: :typed)
      wire = HL7v2.encode(typed)
      {:ok, typed2} = HL7v2.parse(wire, mode: :typed)
      pid2 = Enum.at(typed2.segments, 1)

      assert length(pid2.patient_identifier_list) == 2
      assert hd(pid2.patient_identifier_list).id == "12345"
      assert Enum.at(pid2.patient_identifier_list, 1).id == "67890"
    end

    test "real-world message typed round-trip" do
      text =
        Enum.join(
          [
            "MSH|^~\\&|EPIC|HOSP|LAB|LABFAC|20260322143022.1234+0500||ADT^A01^ADT_A01|MSG00001|P|2.5.1|||AL|NE||UNICODE UTF-8",
            "EVN|A01|20260322143022",
            "PID|1||MRN12345^^^HOSP^MR~SSN123456^^^SSA^SS||Smith^John^Q^Jr^Dr^PhD^L^A||19800515|M||2106-3^White^CDCREC|123 Main St^^Springfield^IL^62704^USA^H~456 Oak Ave^^Chicago^IL^60601^USA^W||^PRN^PH^^1^217^5551234|^WPN^PH^^1^312^5555678|EN^English^HL70296|M^Married^HL70002|CHR^Christian^HL70006|ACC12345^^^HOSP^AN||||||||N",
            "PV1|1|I|W^389^1^HOSP^^N|||12345^Jones^Robert^^^Dr^MD|67890^Smith^Jane|||SUR||||A|||12345^Jones^Robert^^^Dr^MD|IP|VN001^^^HOSP^VN||||||||||||||||||||||||20260322120000",
            "NTE|1|L|Patient allergic to penicillin",
            "NTE|2|L|Family history of diabetes",
            ""
          ],
          "\r"
        )

      {:ok, typed} = HL7v2.parse(text, mode: :typed)

      # Verify parsed data
      msh = Enum.at(typed.segments, 0)
      assert msh.sending_application.namespace_id == "EPIC"
      assert msh.message_type.message_code == "ADT"
      assert msh.message_type.trigger_event == "A01"
      assert msh.message_type.message_structure == "ADT_A01"

      pid = Enum.at(typed.segments, 2)
      assert length(pid.patient_identifier_list) == 2
      assert hd(pid.patient_name).family_name.surname == "Smith"
      assert hd(pid.patient_name).given_name == "John"

      # Round-trip through raw
      raw = HL7v2.TypedParser.to_raw(typed)
      wire = HL7v2.Encoder.encode(raw)
      assert {:ok, _} = HL7v2.parse(wire)
      assert {:ok, _} = HL7v2.parse(wire, mode: :typed)
    end
  end

  # ── 4. Builder round-trip ───────────────────────────────────────────

  describe "builder round-trip" do
    test "build -> encode -> parse typed preserves key fields" do
      msg =
        HL7v2.Message.new("ADT", "A01",
          sending_application: "TEST",
          message_control_id: "CTL1"
        )
        |> HL7v2.Message.add_segment(%HL7v2.Segment.PID{
          set_id: 1,
          patient_identifier_list: [
            %HL7v2.Type.CX{id: "MRN001", identifier_type_code: "MR"}
          ],
          patient_name: [
            %HL7v2.Type.XPN{
              family_name: %HL7v2.Type.FN{surname: "Doe"},
              given_name: "Jane"
            }
          ]
        })

      wire = HL7v2.Message.encode(msg)

      # Must be parseable
      assert {:ok, raw} = HL7v2.parse(wire)
      assert length(raw.segments) == 2

      # Must parse as typed
      {:ok, typed} = HL7v2.parse(wire, mode: :typed)
      msh = hd(typed.segments)
      pid = Enum.at(typed.segments, 1)

      assert msh.sending_application.namespace_id == "TEST"
      assert msh.message_control_id == "CTL1"
      assert msh.message_type.message_code == "ADT"
      assert msh.message_type.trigger_event == "A01"

      assert hd(pid.patient_identifier_list).id == "MRN001"
      assert hd(pid.patient_identifier_list).identifier_type_code == "MR"
      assert hd(pid.patient_name).family_name.surname == "Doe"
      assert hd(pid.patient_name).given_name == "Jane"
    end

    test "builder message re-encodes consistently" do
      msg =
        HL7v2.Message.new("ADT", "A01",
          sending_application: "TEST",
          message_control_id: "CTL1"
        )

      wire1 = HL7v2.Message.encode(msg)
      {:ok, raw} = HL7v2.parse(wire1)
      wire2 = HL7v2.Encoder.encode(raw)

      assert wire1 == wire2
    end

    test "builder with multiple segments" do
      msg =
        HL7v2.Message.new("ADT", "A01",
          sending_application: "TEST",
          message_control_id: "CTL1"
        )
        |> HL7v2.Message.add_segment(%HL7v2.Segment.EVN{
          event_type_code: "A01"
        })
        |> HL7v2.Message.add_segment(%HL7v2.Segment.PID{
          set_id: 1,
          patient_name: [
            %HL7v2.Type.XPN{
              family_name: %HL7v2.Type.FN{surname: "Smith"},
              given_name: "John"
            }
          ]
        })

      wire = HL7v2.Message.encode(msg)
      {:ok, typed} = HL7v2.parse(wire, mode: :typed)

      assert length(typed.segments) == 3

      evn = Enum.at(typed.segments, 1)
      assert evn.event_type_code == "A01"

      pid = Enum.at(typed.segments, 2)
      assert hd(pid.patient_name).family_name.surname == "Smith"
    end
  end

  # ── Helpers ─────────────────────────────────────────────────────────

  defp diff_details(expected, got) do
    expected_segs = String.split(expected, "\r", trim: true)
    got_segs = String.split(got, "\r", trim: true)

    max_segs = max(length(expected_segs), length(got_segs))

    details =
      for i <- 0..(max_segs - 1), reduce: [] do
        acc ->
          e = Enum.at(expected_segs, i)
          g = Enum.at(got_segs, i)

          if e != g do
            ["Segment #{i}:\n  Expected: #{inspect(e)}\n  Got:      #{inspect(g)}" | acc]
          else
            acc
          end
      end

    Enum.reverse(details) |> Enum.join("\n")
  end
end
