defmodule HL7v2.Segment.IN2Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.IN2

  describe "fields/0" do
    test "returns 72 field definitions" do
      assert length(IN2.fields()) == 72
    end
  end

  describe "segment_id/0" do
    test "returns IN2" do
      assert IN2.segment_id() == "IN2"
    end
  end

  describe "parse/1" do
    test "parses insured_employee_id as repeating CX" do
      raw = [[["EMP001", "", "", ["MRN"]]]]

      result = IN2.parse(raw)

      assert %IN2{} = result
      assert [%HL7v2.Type.CX{id: "EMP001"}] = result.insured_employee_id
    end

    test "parses insured_social_security_number" do
      raw = ["", "123-45-6789"]

      result = IN2.parse(raw)

      assert result.insured_social_security_number == "123-45-6789"
    end

    test "parses insured_employer_name_and_id as repeating XCN" do
      raw = ["", "", [["E001", "Acme", "Corp"]]]

      result = IN2.parse(raw)

      assert [%HL7v2.Type.XCN{id_number: "E001"}] = result.insured_employer_name_and_id
    end

    test "parses military_sponsor_name as repeating XPN" do
      raw = List.duplicate("", 8) ++ [[["Smith", "John"]]]

      result = IN2.parse(raw)

      assert [%HL7v2.Type.XPN{}] = result.military_sponsor_name
    end

    test "parses military_id_number" do
      raw = List.duplicate("", 9) ++ ["MIL-12345"]

      result = IN2.parse(raw)

      assert result.military_id_number == "MIL-12345"
    end

    test "parses military_retire_date" do
      raw = List.duplicate("", 16) ++ ["20250615"]

      result = IN2.parse(raw)

      assert result.military_retire_date == ~D[2025-06-15]
    end

    test "parses baby_coverage and combine_baby_bill" do
      raw = List.duplicate("", 18) ++ ["Y", "N"]

      result = IN2.parse(raw)

      assert result.baby_coverage == "Y"
      assert result.combine_baby_bill == "N"
    end

    test "parses payor_id as repeating CX" do
      raw = List.duplicate("", 24) ++ [[["PAY001", "", "", ["PAYOR"]]]]

      result = IN2.parse(raw)

      assert [%HL7v2.Type.CX{id: "PAY001"}] = result.payor_id
    end

    test "parses empty list — all fields nil" do
      result = IN2.parse([])

      assert %IN2{} = result
      assert result.insured_employee_id == nil
      assert result.insured_social_security_number == nil
      assert result.military_id_number == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["", "123-45-6789"]

      encoded = raw |> IN2.parse() |> IN2.encode()
      reparsed = IN2.parse(encoded)

      assert reparsed.insured_social_security_number == "123-45-6789"
    end

    test "trailing nil fields trimmed" do
      in2 = %IN2{insured_social_security_number: "123-45-6789"}

      encoded = IN2.encode(in2)

      assert length(encoded) == 2
    end

    test "encodes all-nil struct to empty list" do
      assert IN2.encode(%IN2{}) == []
    end
  end

  describe "typed parsing integration" do
    test "ADT^A01 with IN2 parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.5.1\r" <>
          "EVN|A01|20260322\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|I\r" <>
          "IN1|1|PPO^Preferred Provider|INS001\r" <>
          "IN2||123-45-6789\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      in2 = Enum.find(msg.segments, &is_struct(&1, IN2))
      assert %IN2{insured_social_security_number: "123-45-6789"} = in2
    end
  end
end
