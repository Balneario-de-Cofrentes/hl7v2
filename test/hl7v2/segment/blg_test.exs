defmodule HL7v2.Segment.BLGTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.BLG
  alias HL7v2.Type.CCD

  describe "fields/0" do
    test "returns 3 field definitions" do
      assert length(BLG.fields()) == 3
    end
  end

  describe "segment_id/0" do
    test "returns BLG" do
      assert BLG.segment_id() == "BLG"
    end
  end

  describe "parse/1" do
    test "parses when_to_charge as CCD" do
      raw = [["D", "20260315"]]

      result = BLG.parse(raw)

      assert %BLG{} = result
      assert %CCD{invocation_event: "D"} = result.when_to_charge
    end

    test "parses charge_type as ID" do
      raw = ["", "P"]

      result = BLG.parse(raw)

      assert result.charge_type == "P"
    end

    test "parses account_id as CX" do
      raw = ["", "", ["ACCT001", "", "", "HOSP"]]

      result = BLG.parse(raw)

      assert %HL7v2.Type.CX{id: "ACCT001"} = result.account_id
    end

    test "parses all three fields together" do
      raw = [["D", "20260315"], "P", ["ACCT001", "", "", "HOSP"]]

      result = BLG.parse(raw)

      assert %CCD{invocation_event: "D"} = result.when_to_charge
      assert result.charge_type == "P"
      assert result.account_id.id == "ACCT001"
    end

    test "parses empty list -- all fields nil" do
      result = BLG.parse([])

      assert %BLG{} = result
      assert result.when_to_charge == nil
      assert result.charge_type == nil
      assert result.account_id == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [["D", "20260315"], "P", ["ACCT001"]]

      encoded = raw |> BLG.parse() |> BLG.encode()
      reparsed = BLG.parse(encoded)

      assert %CCD{invocation_event: "D"} = reparsed.when_to_charge
      assert reparsed.charge_type == "P"
      assert reparsed.account_id.id == "ACCT001"
    end

    test "trailing nil fields trimmed" do
      blg = %BLG{charge_type: "P"}

      encoded = BLG.encode(blg)

      assert length(encoded) == 2
    end

    test "encodes all-nil struct to empty list" do
      assert BLG.encode(%BLG{}) == []
    end
  end

  describe "typed parsing integration" do
    test "message with BLG parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ORM^O01|1|P|2.5.1\r" <>
          "BLG|D^20260315|P|ACCT001\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      blg = Enum.find(msg.segments, &is_struct(&1, BLG))
      assert %BLG{charge_type: "P"} = blg
    end
  end
end
