defmodule HL7v2.Segment.ECRTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.ECR

  describe "fields/0" do
    test "returns 3 field definitions" do
      assert length(ECR.fields()) == 3
    end
  end

  describe "segment_id/0" do
    test "returns ECR" do
      assert ECR.segment_id() == "ECR"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = ECR.parse([])
      assert %ECR{} = result
      assert result.command_response == nil
    end

    test "parses equipment command response" do
      raw = [
        ["OK", "Command accepted", "HL7_RESPONSES"],
        ["20260315120000"]
      ]

      result = ECR.parse(raw)
      assert %HL7v2.Type.CE{identifier: "OK"} = result.command_response
      assert %HL7v2.Type.TS{} = result.date_time_completed
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [["OK", "Accepted"], ["20260315"]]
      encoded = raw |> ECR.parse() |> ECR.encode()
      reparsed = ECR.parse(encoded)
      assert reparsed.command_response.identifier == "OK"
    end

    test "encodes all-nil struct to empty list" do
      assert ECR.encode(%ECR{}) == []
    end
  end
end
