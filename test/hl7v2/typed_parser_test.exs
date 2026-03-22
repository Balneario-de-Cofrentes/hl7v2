defmodule HL7v2.TypedParserTest do
  use ExUnit.Case, async: true

  alias HL7v2.{Encoder, Parser, RawMessage, TypedMessage, TypedParser}
  alias HL7v2.Segment.{EVN, MSH, PID, PV1, ZXX}

  @adt_a01 "MSH|^~\\&|SEND|FAC|RCV|RFAC|20260322120000||ADT^A01|MSG001|P|2.5.1\rEVN|A01|20260322120000\rPID|1||12345^^^MRN||Smith^John||19800101|M\rPV1|1|I|W^389^1\r"

  describe "convert/1" do
    test "converts a full ADT^A01 message with MSH, EVN, PID, PV1 into typed structs" do
      {:ok, raw} = Parser.parse(@adt_a01)
      assert {:ok, %TypedMessage{} = typed} = TypedParser.convert(raw)

      assert typed.type == {"ADT", "A01"}
      assert length(typed.segments) == 4
    end

    test "each segment is the correct struct type" do
      {:ok, raw} = Parser.parse(@adt_a01)
      {:ok, typed} = TypedParser.convert(raw)

      [msh, evn, pid, pv1] = typed.segments

      assert %MSH{} = msh
      assert %EVN{} = evn
      assert %PID{} = pid
      assert %PV1{} = pv1
    end

    test "MSH fields are parsed correctly" do
      {:ok, raw} = Parser.parse(@adt_a01)
      {:ok, typed} = TypedParser.convert(raw)

      %MSH{} = msh = hd(typed.segments)

      assert msh.field_separator == "|"
      assert msh.encoding_characters == "^~\\&"
      assert msh.message_control_id == "MSG001"
    end

    test "PID fields are parsed correctly" do
      {:ok, raw} = Parser.parse(@adt_a01)
      {:ok, typed} = TypedParser.convert(raw)

      pid = Enum.at(typed.segments, 2)
      assert %PID{} = pid
      assert pid.administrative_sex == "M"
    end

    test "PV1 fields are parsed correctly" do
      {:ok, raw} = Parser.parse(@adt_a01)
      {:ok, typed} = TypedParser.convert(raw)

      pv1 = Enum.at(typed.segments, 3)
      assert %PV1{} = pv1
      assert pv1.patient_class == "I"
    end

    test "preserves separators and type from the raw message" do
      {:ok, raw} = Parser.parse(@adt_a01)
      {:ok, typed} = TypedParser.convert(raw)

      assert typed.separators == raw.separators
      assert typed.type == raw.type
    end

    test "Z-segments become ZXX structs" do
      msg =
        "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\r" <>
          "PID|1||12345\r" <>
          "ZPD|1|custom data|more^data\r"

      {:ok, raw} = Parser.parse(msg)
      {:ok, typed} = TypedParser.convert(raw)

      zxx = Enum.at(typed.segments, 2)
      assert %ZXX{segment_id: "ZPD"} = zxx
      assert zxx.raw_fields == ["1", "custom data", ["more", "data"]]
    end

    test "unknown segments are preserved as raw tuples" do
      msg =
        "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\r" <>
          "PID|1||12345\r" <>
          "XYZ|foo|bar\r"

      {:ok, raw} = Parser.parse(msg)
      {:ok, typed} = TypedParser.convert(raw)

      unknown = Enum.at(typed.segments, 2)
      assert {"XYZ", ["foo", "bar"]} = unknown
    end

    test "mixed known, Z-segment, and unknown segments preserve ordering" do
      msg =
        "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\r" <>
          "PID|1||12345\r" <>
          "ZPD|1|custom\r" <>
          "XYZ|unknown\r" <>
          "PV1|1|I\r"

      {:ok, raw} = Parser.parse(msg)
      {:ok, typed} = TypedParser.convert(raw)

      assert length(typed.segments) == 5

      assert %MSH{} = Enum.at(typed.segments, 0)
      assert %PID{} = Enum.at(typed.segments, 1)
      assert %ZXX{segment_id: "ZPD"} = Enum.at(typed.segments, 2)
      assert {"XYZ", _} = Enum.at(typed.segments, 3)
      assert %PV1{} = Enum.at(typed.segments, 4)
    end
  end

  describe "to_raw/1" do
    test "converts typed message back to raw message" do
      {:ok, raw} = Parser.parse(@adt_a01)
      {:ok, typed} = TypedParser.convert(raw)

      raw_again = TypedParser.to_raw(typed)
      assert %RawMessage{} = raw_again
      assert raw_again.type == raw.type
      assert raw_again.separators == raw.separators
      assert length(raw_again.segments) == length(raw.segments)
    end

    test "reverts Z-segments with correct segment name" do
      msg =
        "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\r" <>
          "ZPD|1|custom data\r"

      {:ok, raw} = Parser.parse(msg)
      {:ok, typed} = TypedParser.convert(raw)

      raw_again = TypedParser.to_raw(typed)
      {name, _fields} = Enum.at(raw_again.segments, 1)
      assert name == "ZPD"
    end

    test "reverts unknown segments unchanged" do
      msg =
        "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\r" <>
          "XYZ|foo|bar\r"

      {:ok, raw} = Parser.parse(msg)
      {:ok, typed} = TypedParser.convert(raw)

      raw_again = TypedParser.to_raw(typed)
      assert Enum.at(raw_again.segments, 1) == {"XYZ", ["foo", "bar"]}
    end
  end

  describe "round-trip" do
    test "typed -> to_raw -> encode matches original for ADT^A01" do
      {:ok, raw} = Parser.parse(@adt_a01)
      {:ok, typed} = TypedParser.convert(raw)

      raw_again = TypedParser.to_raw(typed)
      encoded = Encoder.encode(raw_again)

      assert encoded == @adt_a01
    end

    test "typed -> to_raw -> encode matches for message with Z-segments" do
      msg =
        "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\r" <>
          "ZPD|1|custom data\r"

      {:ok, raw} = Parser.parse(msg)
      {:ok, typed} = TypedParser.convert(raw)

      raw_again = TypedParser.to_raw(typed)
      encoded = Encoder.encode(raw_again)

      assert encoded == msg
    end
  end

  describe "parse(text, mode: :typed) end-to-end" do
    test "parses directly into typed message" do
      assert {:ok, %TypedMessage{} = typed} = Parser.parse(@adt_a01, mode: :typed)

      assert typed.type == {"ADT", "A01"}
      assert length(typed.segments) == 4

      assert %MSH{} = Enum.at(typed.segments, 0)
      assert %EVN{} = Enum.at(typed.segments, 1)
      assert %PID{} = Enum.at(typed.segments, 2)
      assert %PV1{} = Enum.at(typed.segments, 3)
    end

    test "returns error for invalid input" do
      assert {:error, _} = Parser.parse("", mode: :typed)
      assert {:error, _} = Parser.parse("INVALID", mode: :typed)
    end
  end
end
