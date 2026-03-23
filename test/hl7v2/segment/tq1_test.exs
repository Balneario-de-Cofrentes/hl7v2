defmodule HL7v2.Segment.TQ1Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.TQ1

  describe "fields/0" do
    test "returns 14 field definitions" do
      assert length(TQ1.fields()) == 14
    end
  end

  describe "segment_id/0" do
    test "returns TQ1" do
      assert TQ1.segment_id() == "TQ1"
    end
  end

  describe "parse/1" do
    test "parses set_id and quantity" do
      raw = ["1", ["1", ["TAB", "Tablet"]]]

      result = TQ1.parse(raw)

      assert %TQ1{} = result
      assert result.set_id == 1
      assert %HL7v2.Type.CQ{quantity: "1"} = result.quantity
    end

    test "parses repeat_pattern as raw" do
      raw = ["1", "", "Q8H"]

      result = TQ1.parse(raw)

      assert result.repeat_pattern == "Q8H"
    end

    test "parses explicit_time as repeating TM" do
      raw = ["1", "", "", "0800"]

      result = TQ1.parse(raw)

      assert [%HL7v2.Type.TM{hour: 8, minute: 0}] = result.explicit_time
    end

    test "parses service_duration" do
      raw = List.duplicate("", 5) ++ [["30", ["MIN", "minutes"]]]

      result = TQ1.parse(raw)

      assert %HL7v2.Type.CQ{quantity: "30"} = result.service_duration
    end

    test "parses start and end date_time" do
      raw = List.duplicate("", 6) ++ [["20260315080000"], ["20260322080000"]]

      result = TQ1.parse(raw)

      assert %HL7v2.Type.TS{
               time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 15, hour: 8}
             } = result.start_date_time

      assert %HL7v2.Type.TS{
               time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22, hour: 8}
             } = result.end_date_time
    end

    test "parses priority as repeating CWE" do
      raw = List.duplicate("", 8) ++ [[["S", "Stat"]]]

      result = TQ1.parse(raw)

      assert [%HL7v2.Type.CWE{identifier: "S", text: "Stat"}] = result.priority
    end

    test "parses condition_text and text_instruction" do
      raw = List.duplicate("", 9) ++ ["If temp > 38C", "Take with food"]

      result = TQ1.parse(raw)

      assert result.condition_text == "If temp > 38C"
      assert result.text_instruction == "Take with food"
    end

    test "parses conjunction and total_occurrences" do
      raw = List.duplicate("", 11) ++ ["S", "", "10"]

      result = TQ1.parse(raw)

      assert result.conjunction == "S"
      assert %HL7v2.Type.NM{value: "10"} = result.total_occurrences
    end

    test "parses empty list — all fields nil" do
      result = TQ1.parse([])

      assert %TQ1{} = result
      assert result.set_id == nil
      assert result.quantity == nil
      assert result.start_date_time == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["1", ["1", ["TAB", "Tablet"]], "", "", "", "", ["20260315080000"]]

      encoded = raw |> TQ1.parse() |> TQ1.encode()
      reparsed = TQ1.parse(encoded)

      assert reparsed.set_id == 1
      assert reparsed.quantity.quantity == "1"
    end

    test "trailing nil fields trimmed" do
      tq1 = %TQ1{set_id: 1, conjunction: "S"}

      encoded = TQ1.encode(tq1)

      assert length(encoded) == 12
    end

    test "encodes all-nil struct to empty list" do
      assert TQ1.encode(%TQ1{}) == []
    end
  end

  describe "typed parsing integration" do
    test "ORM^O01 with TQ1 parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ORM^O01|1|P|2.5.1\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "ORC|NW|ORD001\r" <>
          "TQ1|1|1^TAB^Tablet||0800\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      tq1 = Enum.find(msg.segments, &is_struct(&1, TQ1))
      assert %TQ1{set_id: 1} = tq1
    end
  end
end
