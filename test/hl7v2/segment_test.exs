defmodule HL7v2.SegmentTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment
  alias HL7v2.Type.{ST, SI, CX, CE, XPN, FN, HD}

  describe "parse_field_value/3 with primitive type" do
    test "parses ST value" do
      assert Segment.parse_field_value("hello", ST, 1) == "hello"
    end

    test "parses SI value to integer" do
      assert Segment.parse_field_value("1", SI, 1) == 1
    end
  end

  describe "parse_field_value/3 with composite type" do
    test "parses CX from component list" do
      raw = ["12345", "", "", "MRN", "MR"]

      result = Segment.parse_field_value(raw, CX, 1)

      assert %CX{} = result
      assert result.id == "12345"
      assert result.assigning_authority == %HD{namespace_id: "MRN"}
      assert result.identifier_type_code == "MR"
    end

    test "parses CE from component list" do
      raw = ["code", "text", "system"]

      result = Segment.parse_field_value(raw, CE, 1)

      assert %CE{identifier: "code", text: "text", name_of_coding_system: "system"} = result
    end

    test "parses XPN from component list" do
      raw = ["Smith", "John"]

      result = Segment.parse_field_value(raw, XPN, 1)

      assert %XPN{} = result
      assert result.family_name == %FN{surname: "Smith"}
      assert result.given_name == "John"
    end
  end

  describe "parse_field_value/3 with :raw passthrough" do
    test "passes through string" do
      assert Segment.parse_field_value("raw data", :raw, 1) == "raw data"
    end

    test "passes through list" do
      raw = ["a", "b", "c"]
      assert Segment.parse_field_value(raw, :raw, 1) == raw
    end

    test "passes through nested list" do
      raw = [["a", "b"], ["c", "d"]]
      assert Segment.parse_field_value(raw, :raw, :unbounded) == raw
    end
  end

  describe "parse_field_value/3 with nil/empty" do
    test "nil returns nil" do
      assert Segment.parse_field_value(nil, ST, 1) == nil
      assert Segment.parse_field_value(nil, CX, 1) == nil
      assert Segment.parse_field_value(nil, :raw, 1) == nil
    end

    test "empty string returns nil" do
      assert Segment.parse_field_value("", ST, 1) == nil
      assert Segment.parse_field_value("", CX, 1) == nil
      assert Segment.parse_field_value("", :raw, 1) == nil
    end
  end

  describe "parse_field_value/3 with repeating primitive" do
    test "single string value becomes single-element list" do
      result = Segment.parse_field_value("hello", ST, :unbounded)

      assert result == ["hello"]
    end

    test "list of strings produces list of parsed values" do
      result = Segment.parse_field_value(["one", "two", "three"], ST, :unbounded)

      assert result == ["one", "two", "three"]
    end
  end

  describe "parse_field_value/3 with repeating composite" do
    test "single composite (non-nested list) wraps in list" do
      raw = ["12345", "", "", "MRN", "MR"]

      result = Segment.parse_field_value(raw, CX, :unbounded)

      assert [%CX{id: "12345"}] = result
    end

    test "multiple composites (list of lists) produces list of parsed values" do
      raw = [["12345", "", "", "MRN", "MR"], ["67890", "", "", "SSN", "SS"]]

      result = Segment.parse_field_value(raw, CX, :unbounded)

      assert [%CX{id: "12345"}, %CX{id: "67890"}] = result
    end
  end

  describe "encode_field_value/3 with primitive" do
    test "encodes string via ST" do
      assert Segment.encode_field_value("hello", ST, 1) == "hello"
    end

    test "encodes integer via SI" do
      assert Segment.encode_field_value(1, SI, 1) == "1"
    end
  end

  describe "encode_field_value/3 with composite" do
    test "encodes CX struct to component list" do
      cx = %CX{id: "12345", identifier_type_code: "MR"}

      result = Segment.encode_field_value(cx, CX, 1)

      assert result == ["12345", "", "", "", "MR"]
    end

    test "encodes CE struct to component list" do
      ce = %CE{identifier: "code", text: "text", name_of_coding_system: "system"}

      result = Segment.encode_field_value(ce, CE, 1)

      assert result == ["code", "text", "system"]
    end
  end

  describe "encode_field_value/3 with :raw" do
    test "passes through value" do
      assert Segment.encode_field_value("raw data", :raw, 1) == "raw data"
    end

    test "returns empty string for nil" do
      assert Segment.encode_field_value(nil, :raw, 1) == ""
    end
  end

  describe "encode_field_value/3 with nil" do
    test "returns empty string for nil regardless of type" do
      assert Segment.encode_field_value(nil, ST, 1) == ""
      assert Segment.encode_field_value(nil, CX, 1) == ""
      assert Segment.encode_field_value(nil, SI, 1) == ""
    end
  end

  describe "encode_field_value/3 with repeating values" do
    test "single-element list encodes directly (no repetition wrapper)" do
      result = Segment.encode_field_value(["hello"], ST, :unbounded)

      assert result == "hello"
    end

    test "multiple-element list encodes as repetitions" do
      result = Segment.encode_field_value(["one", "two"], ST, :unbounded)

      assert result == [["one"], ["two"]]
    end

    test "single composite in list encodes directly" do
      cx = %CX{id: "12345", identifier_type_code: "MR"}

      result = Segment.encode_field_value([cx], CX, :unbounded)

      assert result == ["12345", "", "", "", "MR"]
    end

    test "multiple composites in list encode as repetitions" do
      cx1 = %CX{id: "12345", identifier_type_code: "MR"}
      cx2 = %CX{id: "67890", identifier_type_code: "SS"}

      result = Segment.encode_field_value([cx1, cx2], CX, :unbounded)

      assert result == [
               ["12345", "", "", "", "MR"],
               ["67890", "", "", "", "SS"]
             ]
    end

    test "empty list encodes as empty string" do
      assert Segment.encode_field_value([], ST, :unbounded) == ""
      assert Segment.encode_field_value([], CX, :unbounded) == ""
    end
  end

  describe "composite_type?/1" do
    test "returns true for known composite types" do
      assert Segment.composite_type?(CX) == true
      assert Segment.composite_type?(XPN) == true
      assert Segment.composite_type?(CE) == true
      assert Segment.composite_type?(HL7v2.Type.PL) == true
      assert Segment.composite_type?(HL7v2.Type.EI) == true
      assert Segment.composite_type?(HL7v2.Type.HD) == true
      assert Segment.composite_type?(HL7v2.Type.MSG) == true
      assert Segment.composite_type?(HL7v2.Type.XAD) == true
      assert Segment.composite_type?(HL7v2.Type.XTN) == true
      assert Segment.composite_type?(HL7v2.Type.CWE) == true
      assert Segment.composite_type?(HL7v2.Type.PT) == true
      assert Segment.composite_type?(HL7v2.Type.VID) == true
      assert Segment.composite_type?(HL7v2.Type.CNE) == true
      assert Segment.composite_type?(HL7v2.Type.XON) == true
      assert Segment.composite_type?(HL7v2.Type.FN) == true
      assert Segment.composite_type?(HL7v2.Type.SAD) == true
      assert Segment.composite_type?(HL7v2.Type.DR) == true
      assert Segment.composite_type?(HL7v2.Type.TS) == true
      assert Segment.composite_type?(HL7v2.Type.NR) == true
    end

    test "returns false for primitive types" do
      assert Segment.composite_type?(ST) == false
      assert Segment.composite_type?(SI) == false
      assert Segment.composite_type?(HL7v2.Type.ID) == false
      assert Segment.composite_type?(HL7v2.Type.IS) == false
      assert Segment.composite_type?(HL7v2.Type.NM) == false
      assert Segment.composite_type?(HL7v2.Type.DT) == false
      assert Segment.composite_type?(HL7v2.Type.DTM) == false
      assert Segment.composite_type?(HL7v2.Type.TX) == false
      assert Segment.composite_type?(HL7v2.Type.FT) == false
    end
  end
end
