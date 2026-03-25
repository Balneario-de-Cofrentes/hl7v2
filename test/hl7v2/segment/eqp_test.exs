defmodule HL7v2.Segment.EQPTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.EQP

  describe "fields/0" do
    test "returns 5 field definitions" do
      assert length(EQP.fields()) == 5
    end
  end

  describe "segment_id/0" do
    test "returns EQP" do
      assert EQP.segment_id() == "EQP"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = EQP.parse([])
      assert %EQP{} = result
      assert result.event_type == nil
    end

    test "parses equipment log service" do
      raw = [
        ["LOG", "Log Entry", "EQP_EVENTS"],
        "calibration.log",
        ["20260315080000"],
        ["20260315090000"],
        "Calibration completed successfully"
      ]

      result = EQP.parse(raw)
      assert %HL7v2.Type.CE{identifier: "LOG"} = result.event_type
      assert result.file_name == "calibration.log"
      assert %HL7v2.Type.TS{} = result.start_date_time
      assert result.transaction_data == "Calibration completed successfully"
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [["LOG", "Log"], "file.log", ["20260315"], nil, "Transaction data"]
      encoded = raw |> EQP.parse() |> EQP.encode()
      reparsed = EQP.parse(encoded)
      assert reparsed.event_type.identifier == "LOG"
      assert reparsed.file_name == "file.log"
      assert reparsed.transaction_data == "Transaction data"
    end

    test "encodes all-nil struct to empty list" do
      assert EQP.encode(%EQP{}) == []
    end
  end
end
