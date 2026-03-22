defmodule HL7v2.Segment.ExtraFieldsTest do
  use ExUnit.Case, async: true

  alias HL7v2.{Encoder, Parser, TypedParser}
  alias HL7v2.Segment.{MSA, OBR, OBX}

  describe "extra_fields default" do
    test "segments with no extra fields have extra_fields: []" do
      msa = MSA.parse(["AA", "123"])
      assert msa.extra_fields == []
    end

    test "OBX with no extra fields has extra_fields: []" do
      raw = Enum.map(0..18, fn _ -> nil end)
      obx = OBX.parse(raw)
      assert obx.extra_fields == []
    end

    test "OBR with no extra fields has extra_fields: []" do
      raw = Enum.map(0..48, fn _ -> nil end)
      obr = OBR.parse(raw)
      assert obr.extra_fields == []
    end

    test "struct defaults to empty list" do
      assert %MSA{}.extra_fields == []
      assert %OBX{}.extra_fields == []
      assert %OBR{}.extra_fields == []
    end
  end

  describe "OBX extra fields (fields 20-25)" do
    test "captures fields 20-25 into extra_fields" do
      # OBX defines 19 fields (sequences 1-19).
      # Fields at positions 20-25 (0-indexed: 19-24) should be captured.
      raw =
        Enum.map(0..18, fn
          0 -> "1"
          1 -> "ST"
          2 -> ["8480-6", "Systolic BP", "LN"]
          4 -> "120"
          10 -> "F"
          _ -> nil
        end) ++
          ["extra20", "extra21", nil, "extra23", nil, "extra25"]

      obx = OBX.parse(raw)

      assert obx.set_id == 1
      assert obx.value_type == "ST"
      assert obx.observation_result_status == "F"
      assert obx.extra_fields == ["extra20", "extra21", nil, "extra23", nil, "extra25"]
    end

    test "round-trip: OBX with fields 20-25 preserves them through parse -> encode" do
      raw =
        Enum.map(0..18, fn
          0 -> "1"
          1 -> "ST"
          2 -> ["code", "text", "sys"]
          4 -> "value"
          10 -> "F"
          _ -> nil
        end) ++
          ["extra20", "extra21", nil, "extra23"]

      encoded = raw |> OBX.parse() |> OBX.encode()

      # Declared fields end at position 18 (index 18 = field 19).
      # Extra fields start at index 19.
      # trailing nil from "extra23" position may be trimmed, but "extra23" itself should be present.
      assert Enum.at(encoded, 19) == "extra20"
      assert Enum.at(encoded, 20) == "extra21"
      # nil becomes "" via trim_trailing behavior — but extra23 is last non-empty
      assert Enum.at(encoded, 22) == "extra23"
    end
  end

  describe "OBR extra fields (field 50)" do
    test "captures field 50 into extra_fields" do
      # OBR defines 49 fields (sequences 1-49).
      # Field 50 (0-indexed: 49) should be captured.
      raw = Enum.map(0..48, fn _ -> nil end) ++ ["field50_value"]

      obr = OBR.parse(raw)

      assert obr.extra_fields == ["field50_value"]
    end

    test "round-trip: OBR with field 50 preserves it through parse -> encode" do
      raw =
        Enum.map(0..48, fn
          0 -> "1"
          3 -> ["85025", "CBC", "CPT4"]
          _ -> nil
        end) ++ ["field50_value"]

      encoded = raw |> OBR.parse() |> OBR.encode()

      # Field 50 at index 49
      assert Enum.at(encoded, 49) == "field50_value"
    end
  end

  describe "full message round-trip with trailing fields" do
    test "OBX-23 survives typed round-trip through full parse -> encode pipeline" do
      # Build a message with OBX that has fields up to position 23
      msg =
        "MSH|^~\\&|SEND|FAC|RCV|RFAC|20260322||ORU^R01|MSG001|P|2.5.1\r" <>
          "OBR|1|||85025^CBC^CPT4\r" <>
          "OBX|1|ST|8480-6^Systolic BP^LN||120||||||F||||||||||||extra23\r"

      {:ok, raw} = Parser.parse(msg)
      {:ok, typed} = TypedParser.convert(raw)

      # Verify the extra field was captured
      obx = Enum.at(typed.segments, 2)
      assert %OBX{} = obx
      assert "extra23" in obx.extra_fields

      # Round-trip back to wire format
      raw_again = TypedParser.to_raw(typed)
      encoded = Encoder.encode(raw_again)

      # Re-parse as raw to verify OBX-23 is still present
      {:ok, reparsed} = Parser.parse(encoded)
      {_name, obx_fields} = Enum.find(reparsed.segments, fn {n, _} -> n == "OBX" end)

      # Find "extra23" — it should be in a field beyond index 18
      trailing = Enum.drop(obx_fields, 19)
      flat_trailing = List.flatten(trailing)
      assert "extra23" in flat_trailing
    end

    test "message with no extra fields round-trips cleanly" do
      msg =
        "MSH|^~\\&|SEND|FAC|RCV|RFAC|20260322||ADT^A01|MSG001|P|2.5.1\r" <>
          "PID|1||12345^^^MRN||Smith^John||19800101|M\r"

      {:ok, raw} = Parser.parse(msg)
      {:ok, typed} = TypedParser.convert(raw)

      raw_again = TypedParser.to_raw(typed)
      encoded = Encoder.encode(raw_again)

      assert encoded == msg
    end
  end

  describe "MSA with extra fields" do
    test "captures extra fields beyond declared 6" do
      # MSA has 6 fields. Add a 7th.
      raw = ["AA", "123", nil, nil, nil, nil, "extra7"]

      msa = MSA.parse(raw)

      assert msa.acknowledgment_code == "AA"
      assert msa.message_control_id == "123"
      assert msa.extra_fields == ["extra7"]
    end

    test "round-trip preserves extra fields" do
      raw = ["AA", "123", nil, nil, nil, nil, "extra7"]

      encoded = raw |> MSA.parse() |> MSA.encode()

      # extra7 at index 6
      assert Enum.at(encoded, 6) == "extra7"
    end
  end
end
