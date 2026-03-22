defmodule HL7v2.Segment.MSATest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.MSA

  describe "fields/0" do
    test "returns 6 field definitions" do
      assert length(MSA.fields()) == 6
    end
  end

  describe "segment_id/0" do
    test "returns MSA" do
      assert MSA.segment_id() == "MSA"
    end
  end

  describe "parse/1" do
    test "parses acknowledgment_code, message_control_id, and text_message" do
      raw = ["AA", "12345", "Message accepted"]

      result = MSA.parse(raw)

      assert %MSA{} = result
      assert result.acknowledgment_code == "AA"
      assert result.message_control_id == "12345"
      assert result.text_message == "Message accepted"
      assert result.expected_sequence_number == nil
      assert result.delayed_acknowledgment_type == nil
      assert result.error_condition == nil
    end

    test "parses with all 6 fields populated" do
      raw = [
        "AE",
        "CTRL-999",
        "Application error",
        "42",
        "D",
        ["207", "Application internal error", "HL70357"]
      ]

      result = MSA.parse(raw)

      assert result.acknowledgment_code == "AE"
      assert result.message_control_id == "CTRL-999"
      assert result.text_message == "Application error"
      assert %HL7v2.Type.NM{value: "42", original: "42"} = result.expected_sequence_number
      assert result.delayed_acknowledgment_type == "D"

      assert %HL7v2.Type.CE{identifier: "207", text: "Application internal error"} =
               result.error_condition
    end

    test "parses empty list — all fields nil" do
      result = MSA.parse([])

      assert %MSA{} = result
      assert result.acknowledgment_code == nil
      assert result.message_control_id == nil
      assert result.text_message == nil
      assert result.expected_sequence_number == nil
      assert result.delayed_acknowledgment_type == nil
      assert result.error_condition == nil
    end

    test "parses empty string fields as nil" do
      raw = ["", "", ""]

      result = MSA.parse(raw)

      assert result.acknowledgment_code == nil
      assert result.message_control_id == nil
      assert result.text_message == nil
    end
  end

  describe "encode/1" do
    test "round-trip: parse then encode produces equivalent field list" do
      raw = ["AA", "12345", "Message accepted"]

      result = raw |> MSA.parse() |> MSA.encode()

      assert result == ["AA", "12345", "Message accepted"]
    end

    test "round-trip with all 6 fields" do
      raw = [
        "AE",
        "CTRL-999",
        "Application error",
        "42",
        "D",
        ["207", "Application internal error", "HL70357"]
      ]

      encoded = raw |> MSA.parse() |> MSA.encode()

      assert Enum.at(encoded, 0) == "AE"
      assert Enum.at(encoded, 1) == "CTRL-999"
      assert Enum.at(encoded, 2) == "Application error"
      assert Enum.at(encoded, 3) == "42"
      assert Enum.at(encoded, 4) == "D"
      assert Enum.at(encoded, 5) == ["207", "Application internal error", "HL70357"]
    end

    test "trailing nil fields are trimmed" do
      msa = %MSA{acknowledgment_code: "AA", message_control_id: "12345"}

      encoded = MSA.encode(msa)

      assert encoded == ["AA", "12345"]
    end

    test "encodes all-nil struct to empty list" do
      encoded = MSA.encode(%MSA{})

      assert encoded == []
    end
  end
end
