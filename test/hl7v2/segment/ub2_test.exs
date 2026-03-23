defmodule HL7v2.Segment.UB2Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.UB2

  describe "fields/0" do
    test "returns 17 field definitions" do
      assert length(UB2.fields()) == 17
    end
  end

  describe "segment_id/0" do
    test "returns UB2" do
      assert UB2.segment_id() == "UB2"
    end
  end

  describe "parse/1" do
    test "parses set_id and co_insurance_days" do
      raw = ["1", "3"]

      result = UB2.parse(raw)

      assert %UB2{} = result
      assert result.set_id == 1
      assert result.co_insurance_days == "3"
    end

    test "parses condition_code as repeating IS" do
      raw = ["", "", ["01", "02", "03"]]

      result = UB2.parse(raw)

      assert ["01", "02", "03"] = result.condition_code
    end

    test "parses covered_days and non_covered_days" do
      raw = ["", "", "", "10", "2"]

      result = UB2.parse(raw)

      assert result.covered_days == "10"
      assert result.non_covered_days == "2"
    end

    test "preserves value_amount_and_code as raw" do
      raw = List.duplicate("", 5) ++ [["some_raw_data"]]

      result = UB2.parse(raw)

      assert result.value_amount_and_code == ["some_raw_data"]
    end

    test "parses ub92_locator and document_control_number" do
      raw = List.duplicate("", 8) ++ ["CA", "", "US"]

      result = UB2.parse(raw)

      assert result.ub92_locator_2_state == "CA"
      assert result.ub92_locator_31_national == "US"
    end

    test "parses special_visit_count" do
      raw = List.duplicate("", 16) ++ ["2"]

      result = UB2.parse(raw)

      assert %HL7v2.Type.NM{value: "2"} = result.special_visit_count
    end

    test "parses empty list -- all fields nil" do
      result = UB2.parse([])

      assert %UB2{} = result
      assert result.set_id == nil
      assert result.co_insurance_days == nil
      assert result.condition_code == nil
      assert result.special_visit_count == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["1", "3", "", "10", "2"]

      encoded = raw |> UB2.parse() |> UB2.encode()
      reparsed = UB2.parse(encoded)

      assert reparsed.set_id == 1
      assert reparsed.co_insurance_days == "3"
      assert reparsed.covered_days == "10"
      assert reparsed.non_covered_days == "2"
    end

    test "trailing nil fields trimmed" do
      ub2 = %UB2{set_id: 1, co_insurance_days: "5"}

      encoded = UB2.encode(ub2)

      assert length(encoded) == 2
    end

    test "encodes all-nil struct to empty list" do
      assert UB2.encode(%UB2{}) == []
    end
  end

  describe "typed parsing integration" do
    test "ADT^A01 with UB2 parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.5.1\r" <>
          "EVN|A01|20260322\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|I\r" <>
          "UB2|1|3||10|2\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      ub2 = Enum.find(msg.segments, &is_struct(&1, UB2))
      assert %UB2{co_insurance_days: "3", covered_days: "10"} = ub2
    end
  end
end
