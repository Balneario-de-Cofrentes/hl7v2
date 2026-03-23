defmodule HL7v2.Segment.OBXValueTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.OBX
  alias HL7v2.Segment.OBXValue
  alias HL7v2.Type.{CE, CWE, CNE, NM, TS, DTM, NR, HD, CX, EI, XCN, XAD, XPN, XTN, SAD}

  describe "parse/2" do
    test "NM value type returns parsed NM struct" do
      assert %HL7v2.Type.NM{value: "120", original: "120"} = OBXValue.parse("120", "NM")
    end

    test "NM normalizes numeric value" do
      assert %HL7v2.Type.NM{value: "1.2", original: "+01.20"} = OBXValue.parse("+01.20", "NM")
    end

    test "ST value type returns string" do
      assert OBXValue.parse("Normal reading", "ST") == "Normal reading"
    end

    test "TX value type returns text" do
      assert OBXValue.parse("Free text observation", "TX") == "Free text observation"
    end

    test "FT value type returns formatted text" do
      assert OBXValue.parse("Formatted\\.br\\text", "FT") == "Formatted\\.br\\text"
    end

    test "ID value type returns coded value" do
      assert OBXValue.parse("Y", "ID") == "Y"
    end

    test "IS value type returns user-coded value" do
      assert OBXValue.parse("ICU", "IS") == "ICU"
    end

    test "SI value type returns sequence integer" do
      assert OBXValue.parse("42", "SI") == 42
    end

    test "DT value type returns date" do
      assert OBXValue.parse("20260322", "DT") == ~D[2026-03-22]
    end

    test "DTM value type returns datetime struct" do
      result = OBXValue.parse("20260322143000", "DTM")
      assert %DTM{year: 2026, month: 3, day: 22, hour: 14, minute: 30, second: 0} = result
    end

    test "CE value type returns CE struct from component list" do
      result = OBXValue.parse(["784.0", "Headache", "I9C"], "CE")
      assert %CE{identifier: "784.0", text: "Headache", name_of_coding_system: "I9C"} = result
    end

    test "CWE value type returns CWE struct from component list" do
      result = OBXValue.parse(["I48.0", "Paroxysmal AFib", "I10"], "CWE")

      assert %CWE{
               identifier: "I48.0",
               text: "Paroxysmal AFib",
               name_of_coding_system: "I10"
             } = result
    end

    test "CNE value type returns CNE struct from component list" do
      result = OBXValue.parse(["Y", "Yes", "HL70136"], "CNE")
      assert %CNE{identifier: "Y", text: "Yes", name_of_coding_system: "HL70136"} = result
    end

    test "TS value type returns TS struct from component list" do
      result = OBXValue.parse(["20260322143000"], "TS")

      assert %TS{time: %DTM{year: 2026, month: 3, day: 22, hour: 14}} = result
    end

    test "NR value type returns NR struct from component list" do
      result = OBXValue.parse(["2.5", "10"], "NR")
      assert %NR{low: %NM{value: "2.5"}, high: %NM{value: "10"}} = result
    end

    test "HD value type returns HD struct from component list" do
      result = OBXValue.parse(["LAB", "1.2.3", "ISO"], "HD")
      assert %HD{namespace_id: "LAB"} = result
    end

    test "CX value type returns CX struct from component list" do
      result = OBXValue.parse(["12345", "", "", ["MRN"]], "CX")
      assert %CX{id: "12345"} = result
    end

    test "EI value type returns EI struct from component list" do
      result = OBXValue.parse(["ENT001", "LAB", "1.2.3", "ISO"], "EI")
      assert %EI{entity_identifier: "ENT001"} = result
    end

    test "XCN value type returns XCN struct from component list" do
      result = OBXValue.parse(["1234", "Smith", "John"], "XCN")
      assert %XCN{id_number: "1234"} = result
    end

    test "XAD value type returns XAD struct from component list" do
      result = OBXValue.parse(["123 Main St", "", "Springfield"], "XAD")

      assert %XAD{
               street_address: %SAD{street_or_mailing_address: "123 Main St"},
               city: "Springfield"
             } = result
    end

    test "XPN value type returns XPN struct from component list" do
      result = OBXValue.parse(["Smith", "John", "M"], "XPN")
      assert %XPN{} = result
    end

    test "XTN value type returns XTN struct from component list" do
      result = OBXValue.parse(["(555)123-4567"], "XTN")
      assert %XTN{} = result
    end

    test "CF maps to FT (deprecated type)" do
      assert OBXValue.parse("CF formatted text", "CF") == "CF formatted text"
    end

    test "nil value_type preserves raw value" do
      assert OBXValue.parse("raw data", nil) == "raw data"
    end

    test "unknown value_type preserves raw value" do
      assert OBXValue.parse("some data", "FAKE") == "some data"
    end

    test "SN value type returns SN struct from component list" do
      result = OBXValue.parse([">", "100"], "SN")
      assert %HL7v2.Type.SN{comparator: ">"} = result
      assert %HL7v2.Type.NM{value: "100"} = result.num1
    end

    test "ED value type returns ED struct from component list" do
      result = OBXValue.parse(["", "Application", "PDF", "Base64", "JVBER..."], "ED")
      assert %HL7v2.Type.ED{type_of_data: "Application", data_subtype: "PDF"} = result
    end

    test "RP value type returns RP struct from component list" do
      result = OBXValue.parse(["/reports/12345.pdf", "", "Application", "PDF"], "RP")
      assert %HL7v2.Type.RP{pointer: "/reports/12345.pdf", type_of_data: "Application"} = result
    end

    test "nil raw_value returns nil regardless of type" do
      assert OBXValue.parse(nil, "NM") == nil
      assert OBXValue.parse(nil, "CE") == nil
    end

    test "empty string returns nil regardless of type" do
      assert OBXValue.parse("", "NM") == nil
      assert OBXValue.parse("", "CE") == nil
    end

    test "repeating composite values parsed as list of structs" do
      reps = [["784.0", "Headache", "I9C"], ["786.2", "Cough", "I9C"]]
      result = OBXValue.parse(reps, "CWE")

      assert [
               %CWE{identifier: "784.0", text: "Headache"},
               %CWE{identifier: "786.2", text: "Cough"}
             ] = result
    end

    test "repeating primitive values parsed as list" do
      reps = ["100", "200", "300"]
      result = OBXValue.parse(reps, "NM")

      assert [%NM{value: "100"}, %NM{value: "200"}, %NM{value: "300"}] = result
    end
  end

  describe "encode/2" do
    test "encodes NM value back to string" do
      assert OBXValue.encode("120", "NM") == "120"
    end

    test "encodes CE struct back to component list" do
      ce = %CE{identifier: "784.0", text: "Headache", name_of_coding_system: "I9C"}
      assert OBXValue.encode(ce, "CE") == ["784.0", "Headache", "I9C"]
    end

    test "encodes CWE struct back to component list" do
      cwe = %CWE{identifier: "I48.0", text: "AFib", name_of_coding_system: "I10"}
      assert OBXValue.encode(cwe, "CWE") == ["I48.0", "AFib", "I10"]
    end

    test "encodes TS struct back to component list" do
      ts = %TS{time: %DTM{year: 2026, month: 3, day: 22}}
      assert OBXValue.encode(ts, "TS") == ["20260322"]
    end

    test "encodes DT back to date string" do
      assert OBXValue.encode(~D[2026-03-22], "DT") == "20260322"
    end

    test "encodes nil to nil regardless of type" do
      assert OBXValue.encode(nil, "NM") == nil
      assert OBXValue.encode(nil, "CE") == nil
    end

    test "nil value_type returns value as-is" do
      assert OBXValue.encode("raw", nil) == "raw"
    end

    test "unknown value_type returns value as-is" do
      assert OBXValue.encode("some data", "FAKE") == "some data"
    end

    test "encodes list of typed values" do
      values = [
        %CWE{identifier: "784.0", text: "Headache"},
        %CWE{identifier: "786.2", text: "Cough"}
      ]

      result = OBXValue.encode(values, "CWE")

      assert [["784.0", "Headache"], ["786.2", "Cough"]] = result
    end
  end

  describe "type_for/1" do
    test "returns module for known types" do
      assert OBXValue.type_for("NM") == HL7v2.Type.NM
      assert OBXValue.type_for("ST") == HL7v2.Type.ST
      assert OBXValue.type_for("CE") == HL7v2.Type.CE
      assert OBXValue.type_for("CWE") == HL7v2.Type.CWE
      assert OBXValue.type_for("TS") == HL7v2.Type.TS
      assert OBXValue.type_for("XCN") == HL7v2.Type.XCN
    end

    test "returns module for SN, ED, RP types" do
      assert OBXValue.type_for("SN") == HL7v2.Type.SN
      assert OBXValue.type_for("ED") == HL7v2.Type.ED
      assert OBXValue.type_for("RP") == HL7v2.Type.RP
    end

    test "returns nil for unknown types" do
      assert OBXValue.type_for("FAKE") == nil
    end
  end

  describe "known_types/0" do
    test "returns list of type codes" do
      types = OBXValue.known_types()
      assert is_list(types)
      assert "NM" in types
      assert "ST" in types
      assert "CE" in types
      assert "CWE" in types
      assert "TS" in types
    end

    test "includes SN, ED, and RP types" do
      types = OBXValue.known_types()
      assert "SN" in types
      assert "ED" in types
      assert "RP" in types
    end

    test "does not include unknown types" do
      types = OBXValue.known_types()
      refute "FAKE" in types
    end
  end

  describe "integration: full OBX parse with typed dispatch" do
    test "OBX with NM value type produces typed numeric observation" do
      raw = build_obx_fields(%{0 => "1", 1 => "NM", 4 => "14.2", 10 => "F"})
      obx = OBX.parse(raw)

      assert obx.value_type == "NM"
      assert %NM{value: "14.2"} = obx.observation_value
    end

    test "OBX with CWE value type produces CWE struct" do
      raw =
        build_obx_fields(%{
          0 => "1",
          1 => "CWE",
          4 => ["I48.0", "Paroxysmal AFib", "I10"],
          10 => "F"
        })

      obx = OBX.parse(raw)

      assert %CWE{identifier: "I48.0", text: "Paroxysmal AFib"} = obx.observation_value
    end

    test "OBX with TS value type produces TS struct" do
      raw =
        build_obx_fields(%{
          0 => "1",
          1 => "TS",
          4 => ["20260322143000"],
          10 => "F"
        })

      obx = OBX.parse(raw)

      assert %TS{time: %DTM{year: 2026, month: 3, day: 22}} = obx.observation_value
    end

    test "OBX with DT value type produces Date" do
      raw =
        build_obx_fields(%{
          0 => "1",
          1 => "DT",
          4 => "20260322",
          10 => "F"
        })

      obx = OBX.parse(raw)

      assert obx.observation_value == ~D[2026-03-22]
    end

    test "OBX with nil value_type keeps observation raw" do
      raw = build_obx_fields(%{0 => "1", 4 => "untyped value", 10 => "F"})
      obx = OBX.parse(raw)

      assert obx.observation_value == "untyped value"
    end

    test "OBX with unknown value_type keeps observation raw" do
      raw = build_obx_fields(%{0 => "1", 1 => "FAKE", 4 => "binary blob", 10 => "F"})
      obx = OBX.parse(raw)

      assert obx.observation_value == "binary blob"
    end
  end

  describe "round-trip: parse → encode → parse" do
    test "NM round-trip preserves value" do
      raw = build_obx_fields(%{0 => "1", 1 => "NM", 4 => "120", 10 => "F"})
      obx = OBX.parse(raw)
      encoded = OBX.encode(obx)
      obx2 = OBX.parse(encoded)

      assert %NM{value: "120"} = obx2.observation_value
      assert obx2.value_type == "NM"
    end

    test "ST round-trip preserves value" do
      raw = build_obx_fields(%{0 => "1", 1 => "ST", 4 => "text value", 10 => "F"})
      obx = OBX.parse(raw)
      encoded = OBX.encode(obx)
      obx2 = OBX.parse(encoded)

      assert obx2.observation_value == "text value"
    end

    test "CE round-trip preserves value" do
      raw =
        build_obx_fields(%{
          0 => "1",
          1 => "CE",
          4 => ["784.0", "Headache", "I9C"],
          10 => "F"
        })

      obx = OBX.parse(raw)
      assert %CE{identifier: "784.0"} = obx.observation_value

      encoded = OBX.encode(obx)
      obx2 = OBX.parse(encoded)

      assert %CE{identifier: "784.0", text: "Headache", name_of_coding_system: "I9C"} =
               obx2.observation_value
    end

    test "CWE round-trip preserves value" do
      raw =
        build_obx_fields(%{
          0 => "1",
          1 => "CWE",
          4 => ["I48.0", "AFib", "I10"],
          10 => "F"
        })

      obx = OBX.parse(raw)
      assert %CWE{identifier: "I48.0"} = obx.observation_value

      encoded = OBX.encode(obx)
      obx2 = OBX.parse(encoded)

      assert %CWE{identifier: "I48.0", text: "AFib", name_of_coding_system: "I10"} =
               obx2.observation_value
    end

    test "TS round-trip preserves value" do
      raw =
        build_obx_fields(%{
          0 => "1",
          1 => "TS",
          4 => ["20260322"],
          10 => "F"
        })

      obx = OBX.parse(raw)
      assert %TS{time: %DTM{year: 2026, month: 3, day: 22}} = obx.observation_value

      encoded = OBX.encode(obx)
      obx2 = OBX.parse(encoded)

      assert %TS{time: %DTM{year: 2026, month: 3, day: 22}} = obx2.observation_value
    end

    test "nil value_type round-trip preserves raw" do
      raw = build_obx_fields(%{0 => "1", 4 => "raw data", 10 => "F"})
      obx = OBX.parse(raw)
      encoded = OBX.encode(obx)
      obx2 = OBX.parse(encoded)

      assert obx2.observation_value == "raw data"
    end
  end

  defp build_obx_fields(overrides) do
    Enum.map(0..18, fn i -> Map.get(overrides, i) end)
  end
end
