defmodule HL7v2.Segment.IN3Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.IN3

  describe "fields/0" do
    test "returns 28 field definitions" do
      assert length(IN3.fields()) == 28
    end
  end

  describe "segment_id/0" do
    test "returns IN3" do
      assert IN3.segment_id() == "IN3"
    end
  end

  describe "parse/1" do
    test "parses set_id and certification_number" do
      raw = ["1", ["CERT001", "", "", ["AUTH"]]]

      result = IN3.parse(raw)

      assert %IN3{} = result
      assert result.set_id == 1
      assert %HL7v2.Type.CX{id: "CERT001"} = result.certification_number
    end

    test "parses certified_by as repeating XCN" do
      raw = ["1", "", [["DR001", "Smith", "John"]]]

      result = IN3.parse(raw)

      assert [%HL7v2.Type.XCN{id_number: "DR001"}] = result.certified_by
    end

    test "parses certification_required and penalty" do
      raw = ["1", "", "", "Y", ["150.00", "USD"]]

      result = IN3.parse(raw)

      assert result.certification_required == "Y"
      assert %HL7v2.Type.MO{quantity: "150.00", denomination: "USD"} = result.penalty
    end

    test "parses certification date fields" do
      raw = [
        "1",
        "",
        "",
        "",
        "",
        ["20260301120000"],
        ["20260315"],
        "",
        "20260301",
        "20260331"
      ]

      result = IN3.parse(raw)

      assert %HL7v2.Type.TS{
               time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 1, hour: 12}
             } = result.certification_date_time

      assert result.certification_begin_date == ~D[2026-03-01]
      assert result.certification_end_date == ~D[2026-03-31]
    end

    test "parses operator as repeating XCN" do
      raw = List.duplicate("", 7) ++ [[["OP001", "Doe", "Jane"]]]

      result = IN3.parse(raw)

      assert [%HL7v2.Type.XCN{id_number: "OP001"}] = result.operator
    end

    test "parses second_opinion fields" do
      raw = List.duplicate("", 21) ++ ["20260401", "A"]

      result = IN3.parse(raw)

      assert result.second_opinion_date == ~D[2026-04-01]
      assert result.second_opinion_status == "A"
    end

    test "parses empty list — all fields nil" do
      result = IN3.parse([])

      assert %IN3{} = result
      assert result.set_id == nil
      assert result.certification_number == nil
      assert result.penalty == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["1", ["CERT001"], "", "Y", ["150.00", "USD"]]

      encoded = raw |> IN3.parse() |> IN3.encode()
      reparsed = IN3.parse(encoded)

      assert reparsed.set_id == 1
      assert reparsed.certification_required == "Y"
      assert reparsed.penalty.quantity == "150.00"
    end

    test "trailing nil fields trimmed" do
      in3 = %IN3{set_id: 1, certification_required: "Y"}

      encoded = IN3.encode(in3)

      assert length(encoded) == 4
    end

    test "encodes all-nil struct to empty list" do
      assert IN3.encode(%IN3{}) == []
    end
  end

  describe "typed parsing integration" do
    test "ADT^A01 with IN3 parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.5.1\r" <>
          "EVN|A01|20260322\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|I\r" <>
          "IN1|1|PPO^Preferred Provider|INS001\r" <>
          "IN3|1|CERT001|||150.00^USD\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      in3 = Enum.find(msg.segments, &is_struct(&1, IN3))
      assert %IN3{set_id: 1} = in3
    end
  end
end
