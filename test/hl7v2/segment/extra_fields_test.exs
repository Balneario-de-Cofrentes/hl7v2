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
      raw = Enum.map(0..24, fn _ -> nil end)
      obx = OBX.parse(raw)
      assert obx.extra_fields == []
    end

    test "OBR with no extra fields has extra_fields: []" do
      raw = Enum.map(0..49, fn _ -> nil end)
      obr = OBR.parse(raw)
      assert obr.extra_fields == []
    end

    test "struct defaults to empty list" do
      assert %MSA{}.extra_fields == []
      assert %OBX{}.extra_fields == []
      assert %OBR{}.extra_fields == []
    end
  end

  describe "OBX v2.7+ fields (20-25) are declared typed fields" do
    test "fields 20-25 populate struct fields, not extra_fields" do
      # OBX now defines 25 fields (sequences 1-25).
      # Fields 20-25 (0-indexed: 19-24) are declared typed fields.
      raw =
        Enum.map(0..18, fn
          0 -> "1"
          1 -> "ST"
          2 -> ["8480-6", "Systolic BP", "LN"]
          4 -> "120"
          10 -> "F"
          _ -> nil
        end) ++
          [["CHEST", "Chest", "SCT"], ["OBS001", "NS1"], nil, "ORG_NAME", nil, nil]

      obx = OBX.parse(raw)

      assert obx.set_id == 1
      assert obx.value_type == "ST"
      assert obx.observation_result_status == "F"
      assert obx.extra_fields == []

      # v2.7+ fields are now struct fields
      assert [%HL7v2.Type.CWE{identifier: "CHEST", text: "Chest"}] = obx.observation_site

      assert %HL7v2.Type.EI{entity_identifier: "OBS001", namespace_id: "NS1"} =
               obx.observation_instance_identifier

      assert %HL7v2.Type.XON{organization_name: "ORG_NAME"} = obx.performing_organization_name
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
          [["SITE", "Site", "SCT"], ["OBS001", "NS1"], nil, "ORG_NAME"]

      encoded = raw |> OBX.parse() |> OBX.encode()

      # Fields 20-25 are at indices 19-24 in the encoded list
      assert Enum.at(encoded, 19) == ["SITE", "Site", "SCT"]
      assert Enum.at(encoded, 20) == ["OBS001", "NS1"]
      # mood_code (index 21) is nil, skipped in encoding
      assert Enum.at(encoded, 22) == ["ORG_NAME"]
    end
  end

  describe "OBR field 50 is a declared typed field" do
    test "field 50 populates parent_universal_service_identifier, not extra_fields" do
      # OBR now defines 50 fields (sequences 1-50).
      # Field 50 (0-indexed: 49) is parent_universal_service_identifier (CWE).
      raw = Enum.map(0..48, fn _ -> nil end) ++ [["85025", "CBC", "CPT4"]]

      obr = OBR.parse(raw)

      assert obr.extra_fields == []

      assert %HL7v2.Type.CWE{identifier: "85025", text: "CBC", name_of_coding_system: "CPT4"} =
               obr.parent_universal_service_identifier
    end

    test "round-trip: OBR with field 50 preserves it through parse -> encode" do
      raw =
        Enum.map(0..48, fn
          0 -> "1"
          3 -> ["85025", "CBC", "CPT4"]
          _ -> nil
        end) ++ [["99999", "Parent", "LN"]]

      encoded = raw |> OBR.parse() |> OBR.encode()

      # Field 50 at index 49
      assert Enum.at(encoded, 49) == ["99999", "Parent", "LN"]
    end
  end

  describe "full message round-trip with trailing fields" do
    test "OBX-23 survives typed round-trip through full parse -> encode pipeline" do
      # Build a message with OBX that has a value at field position 23
      # (performing_organization_name, now a declared v2.7+ field)
      msg =
        "MSH|^~\\&|SEND|FAC|RCV|RFAC|20260322||ORU^R01|MSG001|P|2.5.1\r" <>
          "OBR|1|||85025^CBC^CPT4\r" <>
          "OBX|1|ST|8480-6^Systolic BP^LN||120||||||F||||||||||||extra23\r"

      {:ok, raw} = Parser.parse(msg)
      {:ok, typed} = TypedParser.convert(raw)

      # Verify the field was captured as a declared struct field (not extra_fields)
      obx = Enum.at(typed.segments, 2)
      assert %OBX{} = obx
      assert %HL7v2.Type.XON{organization_name: "extra23"} = obx.performing_organization_name
      assert obx.extra_fields == []

      # Round-trip back to wire format
      raw_again = TypedParser.to_raw(typed)
      encoded = Encoder.encode(raw_again)

      # Re-parse as raw to verify OBX field 23 is still present
      {:ok, reparsed} = Parser.parse(encoded)
      {_name, obx_fields} = Enum.find(reparsed.segments, fn {n, _} -> n == "OBX" end)

      # Field 23 is at 0-indexed position 22 in the field list
      assert Enum.at(obx_fields, 22) == "extra23"
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

  describe "primitive fields with extra components" do
    test "PID-8 with extra components (M^EXTRA) preserves through round-trip" do
      alias HL7v2.Segment.PID

      # PID-8 (administrative_sex) is IS type, but wire has M^EXTRA
      raw_fields = [
        # set_id
        "1",
        # patient_id
        nil,
        # patient_identifier_list
        "12345",
        # alternate_patient_id
        nil,
        # patient_name
        "Smith^John",
        # mother_maiden_name
        nil,
        # date_of_birth
        "19800101",
        # administrative_sex with extra component
        ["M", "EXTRA"]
      ]

      pid = PID.parse(raw_fields)

      # Value is preserved as list (non-conformant input)
      assert pid.administrative_sex == ["M", "EXTRA"]

      # Encode preserves it
      encoded = PID.encode(pid)
      assert Enum.at(encoded, 7) == ["M", "EXTRA"]
    end

    test "primitive field without extra components parses normally" do
      alias HL7v2.Segment.PID

      raw_fields = ["1", nil, "12345", nil, "Smith^John", nil, "19800101", "M"]
      pid = PID.parse(raw_fields)
      assert pid.administrative_sex == "M"
    end
  end
end
