defmodule HL7v2.Segment.CNSTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.CNS

  describe "fields/0" do
    test "returns 6 field definitions" do
      assert length(CNS.fields()) == 6
    end
  end

  describe "segment_id/0" do
    test "returns CNS" do
      assert CNS.segment_id() == "CNS"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = CNS.parse([])
      assert %CNS{} = result
      assert result.starting_notification_reference_number == nil
      assert result.ending_notification_reference_number == nil
    end

    test "parses notification reference numbers" do
      result = CNS.parse(["100", "200"])
      assert %HL7v2.Type.NM{value: "100"} = result.starting_notification_reference_number
      assert %HL7v2.Type.NM{value: "200"} = result.ending_notification_reference_number
    end

    test "parses notification codes as CE" do
      raw = [nil, nil, nil, nil, ["N001", "Start Code", "LOCAL"], ["N002", "End Code", "LOCAL"]]
      result = CNS.parse(raw)
      assert %HL7v2.Type.CE{identifier: "N001"} = result.starting_notification_code
      assert %HL7v2.Type.CE{identifier: "N002"} = result.ending_notification_code
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["100", "200"]
      encoded = raw |> CNS.parse() |> CNS.encode()
      reparsed = CNS.parse(encoded)
      assert %HL7v2.Type.NM{value: "100"} = reparsed.starting_notification_reference_number
      assert %HL7v2.Type.NM{value: "200"} = reparsed.ending_notification_reference_number
    end

    test "encodes all-nil struct to empty list" do
      assert CNS.encode(%CNS{}) == []
    end
  end
end
