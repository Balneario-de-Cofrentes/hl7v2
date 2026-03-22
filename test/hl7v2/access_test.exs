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
end
