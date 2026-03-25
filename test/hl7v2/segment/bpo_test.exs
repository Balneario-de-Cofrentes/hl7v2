defmodule HL7v2.Segment.BPOTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.BPO

  describe "fields/0" do
    test "returns 14 field definitions" do
      assert length(BPO.fields()) == 14
    end
  end

  describe "segment_id/0" do
    test "returns BPO" do
      assert BPO.segment_id() == "BPO"
    end
  end

  describe "parse/1" do
    test "parses set_id and bp_universal_service_id" do
      raw = ["1", ["PRBC", "Packed Red Blood Cells", "HL70426"]]

      result = BPO.parse(raw)

      assert result.set_id == 1
      assert %HL7v2.Type.CWE{identifier: "PRBC"} = result.bp_universal_service_id
    end

    test "parses bp_quantity as NM" do
      raw = ["1", ["PRBC", "Packed RBC"], "", "2"]

      result = BPO.parse(raw)

      assert %HL7v2.Type.NM{value: "2"} = result.bp_quantity
    end

    test "parses empty list" do
      result = BPO.parse([])

      assert %BPO{} = result
      assert result.set_id == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert BPO.encode(%BPO{}) == []
    end

    test "round-trip preserves data" do
      raw = ["1", ["PRBC", "Packed RBC"]]

      encoded = raw |> BPO.parse() |> BPO.encode()

      assert Enum.at(encoded, 0) == "1"
      assert Enum.at(encoded, 1) == ["PRBC", "Packed RBC"]
    end
  end
end
