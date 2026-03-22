defmodule HL7v2.AccessTest do
  use ExUnit.Case, async: true

  alias HL7v2.Access

  @text "MSH|^~\\&|SEND|FAC||RCV|20260322120000||ADT^A01^ADT_A01|MSG001|P|2.5.1\rPID|1||12345^^^MRN^MR~67890^^^SSN^SS||Smith^John^Q||19800101|M\rPV1|1|I|W^389^1\rNTE|1||Note text\r"

  setup_all do
    {:ok, msg} = HL7v2.parse(@text, mode: :typed)
    %{msg: msg}
  end

  describe "segment-only path" do
    test "PID returns PID segment struct", %{msg: msg} do
      assert %HL7v2.Segment.PID{} = Access.get(msg, "PID")
    end

    test "PV1 returns PV1 segment struct", %{msg: msg} do
      assert %HL7v2.Segment.PV1{} = Access.get(msg, "PV1")
    end

    test "unknown segment returns nil", %{msg: msg} do
      assert Access.get(msg, "XXX") == nil
    end
  end

  describe "field access" do
    test "PID-1 returns set_id", %{msg: msg} do
      assert Access.get(msg, "PID-1") == 1
    end

    test "PID-5 returns first patient name (XPN struct)", %{msg: msg} do
      xpn = Access.get(msg, "PID-5")
      assert %HL7v2.Type.XPN{} = xpn
      assert xpn.family_name.surname == "Smith"
      assert xpn.given_name == "John"
    end

    test "PID-3 returns first patient identifier (CX struct)", %{msg: msg} do
      cx = Access.get(msg, "PID-3")
      assert %HL7v2.Type.CX{} = cx
      assert cx.id == "12345"
      assert cx.identifier_type_code == "MR"
    end

    test "PID-8 returns administrative_sex", %{msg: msg} do
      assert Access.get(msg, "PID-8") == "M"
    end

    test "MSH-9 returns MSG struct", %{msg: msg} do
      msg_type = Access.get(msg, "MSH-9")
      assert %HL7v2.Type.MSG{} = msg_type
      assert msg_type.message_code == "ADT"
      assert msg_type.trigger_event == "A01"
    end

    test "MSH-10 returns message_control_id", %{msg: msg} do
      assert Access.get(msg, "MSH-10") == "MSG001"
    end

    test "NTE-3 returns first comment text", %{msg: msg} do
      assert Access.get(msg, "NTE-3") == "Note text"
    end

    test "unknown field returns nil", %{msg: msg} do
      assert Access.get(msg, "PID-99") == nil
    end
  end

  describe "repetition access" do
    test "PID-3[1] returns first patient identifier", %{msg: msg} do
      cx = Access.get(msg, "PID-3[1]")
      assert %HL7v2.Type.CX{} = cx
      assert cx.id == "12345"
      assert cx.identifier_type_code == "MR"
    end

    test "PID-3[2] returns second patient identifier", %{msg: msg} do
      cx = Access.get(msg, "PID-3[2]")
      assert %HL7v2.Type.CX{} = cx
      assert cx.id == "67890"
      assert cx.identifier_type_code == "SS"
    end

    test "PID-3[3] returns nil for out-of-range repetition", %{msg: msg} do
      assert Access.get(msg, "PID-3[3]") == nil
    end
  end

  describe "component access" do
    test "MSH-9.1 returns message_code", %{msg: msg} do
      assert Access.get(msg, "MSH-9.1") == "ADT"
    end

    test "MSH-9.2 returns trigger_event", %{msg: msg} do
      assert Access.get(msg, "MSH-9.2") == "A01"
    end

    test "MSH-9.3 returns message_structure", %{msg: msg} do
      assert Access.get(msg, "MSH-9.3") == "ADT_A01"
    end

    test "PID-5.1 returns family_name (FN struct) from first XPN", %{msg: msg} do
      fn_val = Access.get(msg, "PID-5.1")
      assert %HL7v2.Type.FN{} = fn_val
      assert fn_val.surname == "Smith"
    end

    test "PID-5.2 returns given_name from first XPN", %{msg: msg} do
      assert Access.get(msg, "PID-5.2") == "John"
    end

    test "PID-3.1 returns id from first CX", %{msg: msg} do
      assert Access.get(msg, "PID-3.1") == "12345"
    end

    test "PID-3.5 returns identifier_type_code from first CX", %{msg: msg} do
      assert Access.get(msg, "PID-3.5") == "MR"
    end

    test "PV1-3.1 returns point_of_care from PL", %{msg: msg} do
      assert Access.get(msg, "PV1-3.1") == "W"
    end

    test "PV1-3.2 returns room from PL", %{msg: msg} do
      assert Access.get(msg, "PV1-3.2") == "389"
    end

    test "PV1-3.3 returns bed from PL", %{msg: msg} do
      assert Access.get(msg, "PV1-3.3") == "1"
    end

    test "out-of-range component returns nil", %{msg: msg} do
      assert Access.get(msg, "MSH-9.99") == nil
    end
  end

  describe "get/3 with default" do
    test "returns value when path resolves", %{msg: msg} do
      xpn = Access.get(msg, "PID-5", "default")
      assert %HL7v2.Type.XPN{} = xpn
    end

    test "returns default for unknown segment", %{msg: msg} do
      assert Access.get(msg, "XXX-1", "default") == "default"
    end

    test "returns default for unknown field", %{msg: msg} do
      assert Access.get(msg, "PID-99", "fallback") == "fallback"
    end
  end

  describe "top-level delegation" do
    test "HL7v2.get/2 works", %{msg: msg} do
      xpn = HL7v2.get(msg, "PID-5")
      assert %HL7v2.Type.XPN{} = xpn
      assert xpn.given_name == "John"
    end

    test "HL7v2.get/3 works", %{msg: msg} do
      assert HL7v2.get(msg, "XXX-1", "nope") == "nope"
    end
  end

  describe "invalid paths" do
    test "returns nil for malformed path", %{msg: msg} do
      assert Access.get(msg, "invalid") == nil
      assert Access.get(msg, "P-5") == nil
      assert Access.get(msg, "pid-5") == nil
      assert Access.get(msg, "") == nil
      assert Access.get(msg, "PID-") == nil
    end
  end

  describe "fetch/2" do
    test "returns {:ok, value} for valid path", %{msg: msg} do
      assert {:ok, %HL7v2.Segment.PID{}} = Access.fetch(msg, "PID")
      assert {:ok, 1} = Access.fetch(msg, "PID-1")
    end

    test "returns {:error, :segment_not_found} for unknown segment", %{msg: msg} do
      assert {:error, :segment_not_found} = Access.fetch(msg, "ZZZ")
      assert {:error, :segment_not_found} = Access.fetch(msg, "ZZZ-1")
    end

    test "returns {:error, :field_not_found} for unknown field", %{msg: msg} do
      assert {:error, :field_not_found} = Access.fetch(msg, "PID-99")
    end

    test "returns {:error, :invalid_path} for malformed path", %{msg: msg} do
      assert {:error, :invalid_path} = Access.fetch(msg, "invalid")
      assert {:error, :invalid_path} = Access.fetch(msg, "")
    end

    test "returns {:ok, nil} for valid path with nil value", %{msg: msg} do
      # PID-23 (birth_place) is not set in our test message
      assert {:ok, nil} = Access.fetch(msg, "PID-23")
    end

    test "HL7v2.fetch/2 delegation works", %{msg: msg} do
      assert {:ok, _} = HL7v2.fetch(msg, "PID")
      assert {:error, :segment_not_found} = HL7v2.fetch(msg, "ZZZ")
    end
  end

  # -- Wildcard path support --

  describe "wildcard paths" do
    @oru_text "MSH|^~\\&|SEND|FAC||RCV||20260322||ORU^R01^ORU_R01|MSG001|P|2.5.1\r" <>
                "PID|1||12345^^^MRN^MR~67890^^^SSN^SS||Smith^John\r" <>
                "OBR|1||ORD001|CBC^Complete Blood Count^LN\r" <>
                "OBX|1|NM|WBC^White Blood Cell^LN||7.5|10*3/uL\r" <>
                "OBX|2|NM|RBC^Red Blood Cell^LN||4.8|10*6/uL\r" <>
                "OBX|3|NM|HGB^Hemoglobin^LN||14.2|g/dL\r"

    setup do
      {:ok, oru} = HL7v2.parse(@oru_text, mode: :typed)
      %{oru: oru}
    end

    test "OBX[*]-5 returns list of all observation values", %{oru: oru} do
      values = Access.get(oru, "OBX[*]-5")
      assert length(values) == 3
      assert values == ["7.5", "4.8", "14.2"]
    end

    test "OBX[*] returns list of all OBX segment structs", %{oru: oru} do
      segments = Access.get(oru, "OBX[*]")
      assert length(segments) == 3
      assert Enum.all?(segments, &is_struct(&1, HL7v2.Segment.OBX))
    end

    test "OBX[2]-5 returns 2nd OBX observation value", %{oru: oru} do
      assert Access.get(oru, "OBX[2]-5") == "4.8"
    end

    test "OBX[1]-5 returns first OBX observation value (same as OBX-5)", %{oru: oru} do
      assert Access.get(oru, "OBX[1]-5") == Access.get(oru, "OBX-5")
    end

    test "OBX[3]-5 returns third OBX observation value", %{oru: oru} do
      assert Access.get(oru, "OBX[3]-5") == "14.2"
    end

    test "OBX[4]-5 returns nil for out-of-range segment index", %{oru: oru} do
      assert Access.get(oru, "OBX[4]-5") == nil
    end

    test "OBX[2] returns 2nd OBX segment struct (no field)", %{oru: oru} do
      seg = Access.get(oru, "OBX[2]")
      assert %HL7v2.Segment.OBX{} = seg
      assert seg.set_id == 2
    end

    test "PID-3[*] returns all repetitions of PID-3", %{oru: oru} do
      reps = Access.get(oru, "PID-3[*]")
      assert length(reps) == 2
      assert Enum.all?(reps, &is_struct(&1, HL7v2.Type.CX))
      assert Enum.map(reps, & &1.id) == ["12345", "67890"]
    end

    test "OBX[*]-3.1 returns identifiers from all OBX segments", %{oru: oru} do
      ids = Access.get(oru, "OBX[*]-3.1")
      assert ids == ["WBC", "RBC", "HGB"]
    end

    test "OBX-5 without wildcard returns first match (backwards compatible)", %{oru: oru} do
      assert Access.get(oru, "OBX-5") == "7.5"
    end

    test "fetch OBX[*]-5 returns {:ok, list}", %{oru: oru} do
      assert {:ok, values} = Access.fetch(oru, "OBX[*]-5")
      assert length(values) == 3
      assert values == ["7.5", "4.8", "14.2"]
    end

    test "fetch OBX[*] returns {:ok, list of segments}", %{oru: oru} do
      assert {:ok, segments} = Access.fetch(oru, "OBX[*]")
      assert length(segments) == 3
    end

    test "fetch ZZZ[*] returns {:error, :segment_not_found}", %{oru: oru} do
      assert {:error, :segment_not_found} = Access.fetch(oru, "ZZZ[*]")
    end

    test "fetch ZZZ[*]-1 returns {:error, :segment_not_found}", %{oru: oru} do
      assert {:error, :segment_not_found} = Access.fetch(oru, "ZZZ[*]-1")
    end

    test "fetch OBX[4] returns {:error, :segment_not_found}", %{oru: oru} do
      assert {:error, :segment_not_found} = Access.fetch(oru, "OBX[4]")
    end

    test "fetch OBX[2]-5 returns {:ok, value}", %{oru: oru} do
      assert {:ok, "4.8"} = Access.fetch(oru, "OBX[2]-5")
    end

    test "fetch PID-3[*] returns {:ok, list}", %{oru: oru} do
      assert {:ok, reps} = Access.fetch(oru, "PID-3[*]")
      assert length(reps) == 2
    end
  end

  describe "wildcard path parsing" do
    test "OBX[*]-5 parses correctly" do
      assert {:ok, parsed} = Access.parse_path("OBX[*]-5")
      assert parsed.segment == "OBX"
      assert parsed.segment_index == :all
      assert parsed.field == 5
      assert parsed.component == nil
      assert parsed.repetition == nil
    end

    test "OBX[2]-5 parses segment index as integer" do
      assert {:ok, parsed} = Access.parse_path("OBX[2]-5")
      assert parsed.segment == "OBX"
      assert parsed.segment_index == 2
      assert parsed.field == 5
    end

    test "PID-3[*] parses repetition wildcard" do
      assert {:ok, parsed} = Access.parse_path("PID-3[*]")
      assert parsed.segment == "PID"
      assert parsed.segment_index == nil
      assert parsed.field == 3
      assert parsed.repetition == :all
    end

    test "OBX[*] parses segment wildcard without field" do
      assert {:ok, parsed} = Access.parse_path("OBX[*]")
      assert parsed.segment == "OBX"
      assert parsed.segment_index == :all
      assert parsed.field == nil
    end

    test "existing paths parse with nil segment_index" do
      assert {:ok, parsed} = Access.parse_path("PID-5")
      assert parsed.segment_index == nil
      assert parsed.field == 5

      assert {:ok, parsed} = Access.parse_path("PID")
      assert parsed.segment_index == nil

      assert {:ok, parsed} = Access.parse_path("PID-3[2]")
      assert parsed.segment_index == nil
      assert parsed.repetition == 2
    end
  end
end
