defmodule HL7v2.Segment.ECDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.ECD

  describe "fields/0" do
    test "returns 5 field definitions" do
      assert length(ECD.fields()) == 5
    end
  end

  describe "segment_id/0" do
    test "returns ECD" do
      assert ECD.segment_id() == "ECD"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = ECD.parse([])
      assert %ECD{} = result
      assert result.reference_command_number == nil
    end

    test "parses equipment command" do
      raw = [
        "1",
        ["LO", "Lock", "HL7_COMMANDS"],
        "Y"
      ]

      result = ECD.parse(raw)
      assert %HL7v2.Type.NM{value: "1"} = result.reference_command_number
      assert %HL7v2.Type.CE{identifier: "LO", text: "Lock"} = result.remote_control_command
      assert result.response_required == "Y"
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["1", ["LO", "Lock"], "Y"]
      encoded = raw |> ECD.parse() |> ECD.encode()
      reparsed = ECD.parse(encoded)
      assert %HL7v2.Type.NM{value: "1"} = reparsed.reference_command_number
      assert reparsed.remote_control_command.identifier == "LO"
    end

    test "encodes all-nil struct to empty list" do
      assert ECD.encode(%ECD{}) == []
    end
  end
end
