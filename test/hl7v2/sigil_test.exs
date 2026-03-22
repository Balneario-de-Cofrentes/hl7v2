defmodule HL7v2.SigilTest do
  use ExUnit.Case, async: true

  import HL7v2.Sigil

  @text "MSH|^~\\&|SEND|FAC||RCV|20260322120000||ADT^A01^ADT_A01|MSG001|P|2.5.1\rPID|1||12345^^^MRN^MR~67890^^^SSN^SS||Smith^John^Q||19800101|M\rPV1|1|I|W^389^1\r"

  setup_all do
    {:ok, msg} = HL7v2.parse(@text, mode: :typed)
    %{msg: msg}
  end

  describe "~h sigil" do
    test "creates a Path struct" do
      path = ~h"PID-5"
      assert %HL7v2.Path{segment: "PID", field: 5, component: nil, repetition: nil} = path
      assert path.raw == "PID-5"
    end

    test "works with HL7v2.get/2", %{msg: msg} do
      assert HL7v2.get(msg, ~h"PID-8") == "M"
    end

    test "works with HL7v2.fetch/2", %{msg: msg} do
      assert {:ok, "M"} = HL7v2.fetch(msg, ~h"PID-8")
    end

    test "works with HL7v2.get/3 default", %{msg: msg} do
      assert HL7v2.get(msg, ~h"PID-23", "default") == nil
    end

    test "segment-only path", %{msg: msg} do
      pid = HL7v2.get(msg, ~h"PID")
      assert %HL7v2.Segment.PID{} = pid
    end

    test "field access returns correct value", %{msg: msg} do
      assert HL7v2.get(msg, ~h"PID-1") == 1
    end

    test "component access", %{msg: msg} do
      assert HL7v2.get(msg, ~h"MSH-9.1") == "ADT"
      assert HL7v2.get(msg, ~h"MSH-9.2") == "A01"
    end

    test "repetition access", %{msg: msg} do
      cx = HL7v2.get(msg, ~h"PID-3[2]")
      assert %HL7v2.Type.CX{} = cx
      assert cx.id == "67890"
      assert cx.identifier_type_code == "SS"
    end

    test "fetch returns error for missing segment at runtime", %{msg: msg} do
      assert {:error, :segment_not_found} = HL7v2.fetch(msg, ~h"ZPD")
    end

    test "known segment with valid field compiles" do
      path = ~h"MSH-9"
      assert %HL7v2.Path{segment: "MSH", field: 9} = path
    end
  end

  describe "compile-time validation" do
    test "valid paths compile" do
      assert %HL7v2.Path{} = ~h"PID"
      assert %HL7v2.Path{} = ~h"PID-5"
      assert %HL7v2.Path{} = ~h"PID-5.1"
      assert %HL7v2.Path{} = ~h"PID-3[2]"
      assert %HL7v2.Path{} = ~h"MSH-9"
      assert %HL7v2.Path{} = ~h"MSH-21"
      assert %HL7v2.Path{} = ~h"PV1-52"
      assert %HL7v2.Path{} = ~h"OBR-49"
    end

    test "path struct fields are populated correctly" do
      path = ~h"PID-3[2]"
      assert path.raw == "PID-3[2]"
      assert path.segment == "PID"
      assert path.field == 3
      assert path.component == nil
      assert path.repetition == 2
    end

    test "component path fields are populated" do
      path = ~h"PID-5.1"
      assert path.segment == "PID"
      assert path.field == 5
      assert path.component == 1
      assert path.repetition == nil
    end

    test "segment-only path fields" do
      path = ~h"PID"
      assert path.segment == "PID"
      assert path.field == nil
      assert path.component == nil
      assert path.repetition == nil
    end
  end

  describe "HL7v2.Path.parse/1 runtime parsing" do
    test "parses valid paths" do
      assert {:ok, %HL7v2.Path{segment: "PID", field: 5}} = HL7v2.Path.parse("PID-5")
    end

    test "returns error for invalid paths" do
      assert {:error, :invalid_path} = HL7v2.Path.parse("invalid")
    end
  end
end
