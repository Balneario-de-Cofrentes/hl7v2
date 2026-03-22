defmodule HL7v2.EncoderTest do
  use ExUnit.Case, async: true

  alias HL7v2.{Encoder, Parser, RawMessage, Separator}

  describe "encode/1" do
    test "encodes a simple message" do
      raw = %RawMessage{
        separators: Separator.default(),
        type: {"ADT", "A01"},
        segments: [
          {"MSH",
           [
             "|",
             "^~\\&",
             "SEND",
             "FAC",
             "",
             "RCV",
             "20240101",
             "",
             ["ADT", "A01"],
             "123",
             "P",
             "2.5"
           ]},
          {"PID", ["1", "", "12345", "", ["Smith", "John"]]}
        ]
      }

      result = Encoder.encode(raw)

      assert result ==
               "MSH|^~\\&|SEND|FAC||RCV|20240101||ADT^A01|123|P|2.5\rPID|1||12345||Smith^John\r"
    end

    test "encodes message with repetitions" do
      raw = %RawMessage{
        separators: Separator.default(),
        type: {"ADT", "A01"},
        segments: [
          {"MSH",
           ["|", "^~\\&", "S", "F", "", "R", "20240101", "", ["ADT", "A01"], "1", "P", "2.5"]},
          {"PID",
           ["1", "", [["12345", "", "", "MRN"], ["67890", "", "", "SSN"]], "", ["Smith", "John"]]}
        ]
      }

      result = Encoder.encode(raw)
      assert String.contains?(result, "12345^^^MRN~67890^^^SSN")
    end

    test "encodes MSH with correct field separator handling" do
      raw = %RawMessage{
        separators: Separator.default(),
        type: {"ACK", ""},
        segments: [
          {"MSH", ["|", "^~\\&", "RCV", "FAC", "", "", "20240101", "", "ACK", "999", "P", "2.5"]}
        ]
      }

      result = Encoder.encode(raw)
      assert String.starts_with?(result, "MSH|^~\\&|RCV|FAC")
    end

    test "encodes message with sub-components" do
      raw = %RawMessage{
        separators: Separator.default(),
        type: {"ADT", "A01"},
        segments: [
          {"MSH",
           ["|", "^~\\&", "S", "F", "", "R", "20240101", "", ["ADT", "A01"], "1", "P", "2.5"]},
          {"PID", ["1", "", ["12345", "5", "M11", ["ADT1", "MR", "HOSP"]], "", ["Smith", "John"]]}
        ]
      }

      result = Encoder.encode(raw)
      assert String.contains?(result, "12345^5^M11^ADT1&MR&HOSP")
    end

    test "preserves trailing empty fields for lossless round-trip" do
      raw = %RawMessage{
        separators: Separator.default(),
        type: {"ADT", "A01"},
        segments: [
          {"MSH",
           ["|", "^~\\&", "S", "F", "", "R", "20240101", "", ["ADT", "A01"], "1", "P", "2.5"]},
          {"PID", ["1", "", "12345", "", "", "", ""]}
        ]
      }

      result = Encoder.encode(raw)
      # Trailing empty fields are preserved for lossless round-trip
      assert result =~ ~r/PID\|1\|\|12345\|\|\|\|\r/
    end

    test "preserves middle empty fields" do
      raw = %RawMessage{
        separators: Separator.default(),
        type: {"ADT", "A01"},
        segments: [
          {"MSH",
           ["|", "^~\\&", "S", "F", "", "R", "20240101", "", ["ADT", "A01"], "1", "P", "2.5"]},
          {"PID", ["1", "", "", "", ["Smith", "John"]]}
        ]
      }

      result = Encoder.encode(raw)
      assert result =~ ~r/PID\|1\|\|\|\|Smith\^John\r/
    end

    test "preserves trailing empty components for lossless round-trip" do
      raw = %RawMessage{
        separators: Separator.default(),
        type: {"ADT", "A01"},
        segments: [
          {"MSH",
           ["|", "^~\\&", "S", "F", "", "R", "20240101", "", ["ADT", "A01"], "1", "P", "2.5"]},
          {"PID", ["1", "", "12345", "", ["Smith", "John", "", "", ""]]}
        ]
      }

      result = Encoder.encode(raw)
      # Trailing empty components are preserved for lossless round-trip
      assert result =~ ~r/Smith\^John\^\^\^\r/
    end

    test "encodes with custom separators" do
      sep = %Separator{field: ?!, component: ?@, repetition: ?#, escape: ?$, sub_component: ?%}

      raw = %RawMessage{
        separators: sep,
        type: {"ADT", "A01"},
        segments: [
          {"MSH",
           ["!", "@#$%", "S", "F", "", "R", "20240101", "", ["ADT", "A01"], "1", "P", "2.5"]},
          {"PID", ["1", "", "12345", "", ["Smith", "John"]]}
        ]
      }

      result = Encoder.encode(raw)
      assert String.starts_with?(result, "MSH!@#$%!S!F")
      assert result =~ ~r/Smith@John/
    end
  end

  describe "round-trip with parser" do
    test "parse then encode produces identical output for simple message" do
      original = "MSH|^~\\&|SEND|FAC||RCV|20240101||ADT^A01|123|P|2.5\rPID|1||12345||Smith^John\r"
      assert {:ok, raw} = Parser.parse(original)
      assert Encoder.encode(raw) == original
    end

    test "parse then encode preserves repetitions" do
      original =
        "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\rPID|1||12345^^^MRN~67890^^^SSN||Smith^John\r"

      assert {:ok, raw} = Parser.parse(original)
      assert Encoder.encode(raw) == original
    end

    test "parse then encode preserves sub-components" do
      original =
        "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\rPID|1||12345^5^M11^ADT1&MR&HOSP||Smith^John\r"

      assert {:ok, raw} = Parser.parse(original)
      assert Encoder.encode(raw) == original
    end

    test "parse then encode preserves empty fields" do
      original = "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\rPID|1||||Smith^John\r"
      assert {:ok, raw} = Parser.parse(original)
      assert Encoder.encode(raw) == original
    end

    test "parse then encode preserves explicit null" do
      original = "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\rPID|1||\"\"||Smith^John\r"
      assert {:ok, raw} = Parser.parse(original)
      assert Encoder.encode(raw) == original
    end
  end
end
