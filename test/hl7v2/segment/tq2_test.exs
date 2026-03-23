defmodule HL7v2.Segment.TQ2Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.TQ2

  describe "fields/0" do
    test "returns 10 field definitions" do
      assert length(TQ2.fields()) == 10
    end
  end

  describe "segment_id/0" do
    test "returns TQ2" do
      assert TQ2.segment_id() == "TQ2"
    end
  end

  describe "parse/1" do
    test "parses set_id and sequence_results_flag" do
      raw = ["1", "S"]

      result = TQ2.parse(raw)

      assert %TQ2{} = result
      assert result.set_id == 1
      assert result.sequence_results_flag == "S"
    end

    test "parses related_placer_number as repeating EI" do
      raw = ["1", "", [["PL001", "", "", ""], ["PL002", "", "", ""]]]

      result = TQ2.parse(raw)

      assert [
               %HL7v2.Type.EI{entity_identifier: "PL001"},
               %HL7v2.Type.EI{entity_identifier: "PL002"}
             ] = result.related_placer_number
    end

    test "parses related_filler_number as repeating EI" do
      raw = ["1", "", "", [["FL001"]]]

      result = TQ2.parse(raw)

      assert [%HL7v2.Type.EI{entity_identifier: "FL001"}] = result.related_filler_number
    end

    test "parses sequence_condition_code and cyclic indicator" do
      raw = List.duplicate("", 5) ++ ["EE", "F"]

      result = TQ2.parse(raw)

      assert result.sequence_condition_code == "EE"
      assert result.cyclic_entry_exit_indicator == "F"
    end

    test "parses sequence_condition_time_interval as CQ" do
      raw = List.duplicate("", 7) ++ [["10", ["MIN", "minutes"]]]

      result = TQ2.parse(raw)

      assert %HL7v2.Type.CQ{quantity: "10"} = result.sequence_condition_time_interval
    end

    test "parses cyclic_group_maximum_number_of_repeats" do
      raw = List.duplicate("", 8) ++ ["3"]

      result = TQ2.parse(raw)

      assert %HL7v2.Type.NM{value: "3"} = result.cyclic_group_maximum_number_of_repeats
    end

    test "parses special_service_request_relationship" do
      raw = List.duplicate("", 9) ++ ["N"]

      result = TQ2.parse(raw)

      assert result.special_service_request_relationship == "N"
    end

    test "parses empty list — all fields nil" do
      result = TQ2.parse([])

      assert %TQ2{} = result
      assert result.set_id == nil
      assert result.sequence_results_flag == nil
      assert result.related_placer_number == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["1", "S", "", "", "", "EE"]

      encoded = raw |> TQ2.parse() |> TQ2.encode()
      reparsed = TQ2.parse(encoded)

      assert reparsed.set_id == 1
      assert reparsed.sequence_results_flag == "S"
      assert reparsed.sequence_condition_code == "EE"
    end

    test "trailing nil fields trimmed" do
      tq2 = %TQ2{set_id: 1, sequence_results_flag: "S"}

      encoded = TQ2.encode(tq2)

      assert length(encoded) == 2
    end

    test "encodes all-nil struct to empty list" do
      assert TQ2.encode(%TQ2{}) == []
    end
  end

  describe "typed parsing integration" do
    test "ORM^O01 with TQ2 parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ORM^O01|1|P|2.5.1\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "ORC|NW|ORD001\r" <>
          "TQ1|1|1^TAB^Tablet\r" <>
          "TQ2|1|S||||\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      tq2 = Enum.find(msg.segments, &is_struct(&1, TQ2))
      assert %TQ2{set_id: 1, sequence_results_flag: "S"} = tq2
    end
  end
end
