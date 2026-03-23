defmodule HL7v2.Segment.UB1Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.UB1

  describe "fields/0" do
    test "returns 23 field definitions" do
      assert length(UB1.fields()) == 23
    end
  end

  describe "segment_id/0" do
    test "returns UB1" do
      assert UB1.segment_id() == "UB1"
    end
  end

  describe "parse/1" do
    test "parses set_id" do
      raw = ["1"]

      result = UB1.parse(raw)

      assert %UB1{} = result
      assert result.set_id == 1
    end

    test "parses condition_code as repeating IS" do
      raw = List.duplicate("", 6) ++ [["01", "02", "03"]]

      result = UB1.parse(raw)

      assert ["01", "02", "03"] = result.condition_code
    end

    test "parses priority" do
      raw = List.duplicate("", 13) ++ ["1"]

      result = UB1.parse(raw)

      assert result.priority == "1"
    end

    test "parses number_of_grace_days" do
      raw = List.duplicate("", 15) ++ ["5"]

      result = UB1.parse(raw)

      assert %HL7v2.Type.NM{value: "5"} = result.number_of_grace_days
    end

    test "preserves withdrawn fields as raw" do
      raw = ["", "some_old_data", "more_old_data"]

      result = UB1.parse(raw)

      assert result.field_2 == "some_old_data"
      assert result.field_3 == "more_old_data"
    end

    test "parses empty list -- all fields nil" do
      result = UB1.parse([])

      assert %UB1{} = result
      assert result.set_id == nil
      assert result.condition_code == nil
      assert result.priority == nil
      assert result.number_of_grace_days == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["1", "", "", "", "", "", ["01", "02"]]

      encoded = raw |> UB1.parse() |> UB1.encode()
      reparsed = UB1.parse(encoded)

      assert reparsed.set_id == 1
    end

    test "trailing nil fields trimmed" do
      ub1 = %UB1{set_id: 1}

      encoded = UB1.encode(ub1)

      assert length(encoded) == 1
    end

    test "encodes all-nil struct to empty list" do
      assert UB1.encode(%UB1{}) == []
    end
  end

  describe "typed parsing integration" do
    test "ADT^A01 with UB1 parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.5.1\r" <>
          "EVN|A01|20260322\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|I\r" <>
          "UB1|1\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      ub1 = Enum.find(msg.segments, &is_struct(&1, UB1))
      assert %UB1{} = ub1
      assert ub1.set_id == 1
    end
  end
end
