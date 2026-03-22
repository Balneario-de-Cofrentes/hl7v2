defmodule HL7v2.ParserTest do
  use ExUnit.Case, async: true

  alias HL7v2.Parser

  @fixtures_dir Path.expand("../fixtures", __DIR__)

  describe "parse/2 basic" do
    test "parses a simple ADT^A01 message" do
      msg = "MSH|^~\\&|SEND|FAC||RCV|20240101||ADT^A01|123|P|2.5\rPID|1||12345||Smith^John\r"

      assert {:ok, raw} = Parser.parse(msg)
      assert raw.type == {"ADT", "A01"}
      assert length(raw.segments) == 2

      [{"MSH", msh_fields}, {"PID", pid_fields}] = raw.segments

      # MSH-1 = field separator
      assert Enum.at(msh_fields, 0) == "|"
      # MSH-2 = encoding characters
      assert Enum.at(msh_fields, 1) == "^~\\&"
      # MSH-3 = SendingApplication
      assert Enum.at(msh_fields, 2) == "SEND"
      # MSH-4 = SendingFacility
      assert Enum.at(msh_fields, 3) == "FAC"

      # PID-1 = SetID
      assert Enum.at(pid_fields, 0) == "1"
      # PID-3 = PatientIdentifierList
      assert Enum.at(pid_fields, 2) == "12345"
      # PID-5 = PatientName (components)
      assert Enum.at(pid_fields, 4) == ["Smith", "John"]
    end

    test "parses message with three-part message type" do
      msg = "MSH|^~\\&|S|F||R|20240101||ADT^A01^ADT_A01|1|P|2.5\r"

      assert {:ok, raw} = Parser.parse(msg)
      assert raw.type == {"ADT", "A01", "ADT_A01"}
    end

    test "parses message with repetitions" do
      msg =
        "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\r" <>
          "PID|1||12345^^^MRN~67890^^^SSN||Smith^John\r"

      assert {:ok, raw} = Parser.parse(msg)
      [_, {"PID", pid_fields}] = raw.segments

      # PID-3 has repetitions — should be a list of component-lists
      pid_3 = Enum.at(pid_fields, 2)
      assert [["12345", "", "", "MRN"], ["67890", "", "", "SSN"]] = pid_3
    end

    test "parses message with sub-components" do
      msg =
        "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\r" <>
          "PID|1||12345^5^M11^ADT1&MR&HOSP||Smith^John\r"

      assert {:ok, raw} = Parser.parse(msg)
      [_, {"PID", pid_fields}] = raw.segments

      pid_3 = Enum.at(pid_fields, 2)
      # PID-3 has components, and component 4 has sub-components
      assert ["12345", "5", "M11", ["ADT1", "MR", "HOSP"]] = pid_3
    end

    test "parses MSH-9 with only message code (no trigger event)" do
      msg = "MSH|^~\\&|S|F||R|20240101||ACK|1|P|2.5\r"

      assert {:ok, raw} = Parser.parse(msg)
      assert raw.type == {"ACK", ""}
    end
  end

  describe "parse/2 line endings" do
    test "handles CR line endings" do
      msg = "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\rPID|1||12345\r"
      assert {:ok, raw} = Parser.parse(msg)
      assert length(raw.segments) == 2
    end

    test "handles LF line endings" do
      msg = "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\nPID|1||12345\n"
      assert {:ok, raw} = Parser.parse(msg)
      assert length(raw.segments) == 2
    end

    test "handles CRLF line endings" do
      msg = "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\r\nPID|1||12345\r\n"
      assert {:ok, raw} = Parser.parse(msg)
      assert length(raw.segments) == 2
    end

    test "handles mixed line endings" do
      msg = "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\rPID|1||12345\r\nPV1|1|I\n"
      assert {:ok, raw} = Parser.parse(msg)
      assert length(raw.segments) == 3
    end
  end

  describe "parse/2 empty and null fields" do
    test "preserves empty fields" do
      msg = "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\rPID|1||||Smith^John\r"
      assert {:ok, raw} = Parser.parse(msg)
      [_, {"PID", pid_fields}] = raw.segments

      # Fields 2, 3, 4 are empty
      assert Enum.at(pid_fields, 1) == ""
      assert Enum.at(pid_fields, 2) == ""
      assert Enum.at(pid_fields, 3) == ""
      # Field 5 has value
      assert Enum.at(pid_fields, 4) == ["Smith", "John"]
    end

    test "preserves explicit null (double-quoted empty)" do
      msg = "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\rPID|1||\"\"||Smith^John\r"
      assert {:ok, raw} = Parser.parse(msg)
      [_, {"PID", pid_fields}] = raw.segments

      # PID-3 is explicit null
      assert Enum.at(pid_fields, 2) == "\"\""
    end

    test "handles trailing field omission" do
      msg = "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\rPID|1||12345\r"
      assert {:ok, raw} = Parser.parse(msg)
      [_, {"PID", pid_fields}] = raw.segments

      # Only 3 fields after segment name
      assert length(pid_fields) == 3
    end
  end

  describe "parse/2 MSH special handling" do
    test "MSH-1 is the field separator as a single-byte binary" do
      msg = "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\r"
      assert {:ok, raw} = Parser.parse(msg)
      [{"MSH", msh_fields}] = raw.segments

      assert Enum.at(msh_fields, 0) == "|"
    end

    test "MSH-2 is the encoding characters as a literal string" do
      msg = "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\r"
      assert {:ok, raw} = Parser.parse(msg)
      [{"MSH", msh_fields}] = raw.segments

      assert Enum.at(msh_fields, 1) == "^~\\&"
    end

    test "MSH field numbering matches standard" do
      # MSH-1=|, MSH-2=^~\&, MSH-3=S, MSH-4=F, MSH-5=empty, MSH-6=R,
      # MSH-7=datetime, MSH-8=empty(security), MSH-9=type, MSH-10=controlid,
      # MSH-11=P, MSH-12=version
      msg = "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\r"
      assert {:ok, raw} = Parser.parse(msg)
      [{"MSH", fields}] = raw.segments

      # MSH-1
      assert Enum.at(fields, 0) == "|"
      # MSH-2
      assert Enum.at(fields, 1) == "^~\\&"
      # MSH-3
      assert Enum.at(fields, 2) == "S"
      # MSH-4
      assert Enum.at(fields, 3) == "F"
      # MSH-5
      assert Enum.at(fields, 4) == ""
      # MSH-6
      assert Enum.at(fields, 5) == "R"
      # MSH-7
      assert Enum.at(fields, 6) == "20240101"
      # MSH-8
      assert Enum.at(fields, 7) == ""
      # MSH-9
      assert Enum.at(fields, 8) == ["ADT", "A01"]
      # MSH-10
      assert Enum.at(fields, 9) == "1"
      # MSH-11
      assert Enum.at(fields, 10) == "P"
      # MSH-12
      assert Enum.at(fields, 11) == "2.5"
    end

    test "handles custom delimiters" do
      msg = "MSH!@#$%!S!F!!R!20240101!!ADT@A01!1!P!2.5\r"
      assert {:ok, raw} = Parser.parse(msg)
      assert raw.separators.field == ?!
      assert raw.separators.component == ?@
      assert raw.separators.repetition == ?#
      assert raw.separators.escape == ?$
      assert raw.separators.sub_component == ?%

      [{"MSH", fields}] = raw.segments
      assert Enum.at(fields, 0) == "!"
      assert Enum.at(fields, 1) == "@#$%"
      assert Enum.at(fields, 8) == ["ADT", "A01"]
    end
  end

  describe "parse/2 error cases" do
    test "returns error for empty input" do
      assert {:error, :empty_message} = Parser.parse("")
    end

    test "returns error for missing MSH" do
      assert {:error, :not_msh} = Parser.parse("PID|1||12345\r")
    end

    test "returns error for truncated MSH" do
      assert {:error, :insufficient_encoding_characters} = Parser.parse("MSH|^~\r")
    end

    test "returns error for unknown mode" do
      msg = "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\r"
      assert {:error, {:unknown_mode, :invalid}} = Parser.parse(msg, mode: :invalid)
    end

    test "typed mode returns a typed message" do
      msg = "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\r"
      assert {:ok, %HL7v2.TypedMessage{}} = Parser.parse(msg, mode: :typed)
    end
  end

  describe "parse/2 fixture files" do
    test "parses ADT^A01 fixture" do
      msg = read_fixture("adt_a01.hl7")
      assert {:ok, raw} = Parser.parse(msg)
      assert raw.type == {"ADT", "A01", "ADT_A01"}

      segment_names = Enum.map(raw.segments, &elem(&1, 0))
      assert segment_names == ["MSH", "EVN", "PID", "PV1", "NK1", "AL1", "DG1"]
    end

    test "parses ADT^A08 fixture" do
      msg = read_fixture("adt_a08.hl7")
      assert {:ok, raw} = Parser.parse(msg)
      assert raw.type == {"ADT", "A08", "ADT_A01"}
    end

    test "parses ORM^O01 fixture" do
      msg = read_fixture("orm_o01.hl7")
      assert {:ok, raw} = Parser.parse(msg)
      assert raw.type == {"ORM", "O01", "ORM_O01"}

      segment_names = Enum.map(raw.segments, &elem(&1, 0))
      assert segment_names == ["MSH", "PID", "PV1", "ORC", "OBR"]
    end

    test "parses ORU^R01 fixture" do
      msg = read_fixture("oru_r01.hl7")
      assert {:ok, raw} = Parser.parse(msg)
      assert raw.type == {"ORU", "R01", "ORU_R01"}

      segment_names = Enum.map(raw.segments, &elem(&1, 0))

      assert segment_names == [
               "MSH",
               "PID",
               "PV1",
               "ORC",
               "OBR",
               "OBX",
               "OBX",
               "OBX",
               "OBX",
               "NTE"
             ]
    end

    test "parses fixture with sub-components" do
      msg = read_fixture("adt_a04_subcomponents.hl7")
      assert {:ok, raw} = Parser.parse(msg)
      assert raw.type == {"ADT", "A04"}

      [_, _, {"PID", pid_fields} | _] = raw.segments

      # PID-3 should have repetitions with sub-components
      pid_3 = Enum.at(pid_fields, 2)
      assert is_list(pid_3)
    end
  end

  describe "parse/2 preserves structure" do
    test "unknown segments are preserved" do
      msg =
        "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\r" <>
          "ZPI|1|custom data|more^data\r"

      assert {:ok, raw} = Parser.parse(msg)
      assert length(raw.segments) == 2
      [_, {"ZPI", zpi_fields}] = raw.segments
      assert Enum.at(zpi_fields, 0) == "1"
      assert Enum.at(zpi_fields, 1) == "custom data"
      assert Enum.at(zpi_fields, 2) == ["more", "data"]
    end

    test "preserves segment order" do
      msg =
        "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\r" <>
          "PID|1\r" <>
          "PV1|1\r" <>
          "OBX|1\r" <>
          "OBX|2\r"

      assert {:ok, raw} = Parser.parse(msg)
      names = Enum.map(raw.segments, &elem(&1, 0))
      assert names == ["MSH", "PID", "PV1", "OBX", "OBX"]
    end
  end

  defp read_fixture(name) do
    Path.join(@fixtures_dir, name) |> File.read!()
  end
end
