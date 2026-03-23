defmodule HL7v2.Segment.CTITest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.CTI

  describe "fields/0" do
    test "returns 3 field definitions" do
      assert length(CTI.fields()) == 3
    end
  end

  describe "segment_id/0" do
    test "returns CTI" do
      assert CTI.segment_id() == "CTI"
    end
  end

  describe "parse/1" do
    test "parses sponsor_study_id as EI" do
      raw = [["STUDY001", "SPONSOR_NS", "2.16.840.1.113883", "ISO"]]

      result = CTI.parse(raw)

      assert %CTI{} = result

      assert %HL7v2.Type.EI{
               entity_identifier: "STUDY001",
               namespace_id: "SPONSOR_NS"
             } = result.sponsor_study_id
    end

    test "parses study_phase_identifier as CE" do
      raw = [["STUDY001"], ["P2", "Phase 2", "HL7_PHASES"]]

      result = CTI.parse(raw)

      assert %HL7v2.Type.CE{identifier: "P2", text: "Phase 2"} = result.study_phase_identifier
    end

    test "parses study_scheduled_time_point as CE" do
      raw = [["STUDY001"], "", ["TP3", "Visit 3", "STUDY_TIMEPOINTS"]]

      result = CTI.parse(raw)

      assert %HL7v2.Type.CE{identifier: "TP3", text: "Visit 3"} =
               result.study_scheduled_time_point
    end

    test "parses all three fields together" do
      raw = [
        ["STUDY001", "SPONSOR"],
        ["P2", "Phase 2"],
        ["TP3", "Visit 3"]
      ]

      result = CTI.parse(raw)

      assert result.sponsor_study_id.entity_identifier == "STUDY001"
      assert result.study_phase_identifier.identifier == "P2"
      assert result.study_scheduled_time_point.identifier == "TP3"
    end

    test "parses empty list -- all fields nil" do
      result = CTI.parse([])

      assert %CTI{} = result
      assert result.sponsor_study_id == nil
      assert result.study_phase_identifier == nil
      assert result.study_scheduled_time_point == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [["STUDY001", "SPONSOR"], ["P2", "Phase 2"]]

      encoded = raw |> CTI.parse() |> CTI.encode()
      reparsed = CTI.parse(encoded)

      assert reparsed.sponsor_study_id.entity_identifier == "STUDY001"
      assert reparsed.study_phase_identifier.identifier == "P2"
    end

    test "trailing nil fields trimmed" do
      cti = %CTI{
        sponsor_study_id: %HL7v2.Type.EI{entity_identifier: "STUDY001"}
      }

      encoded = CTI.encode(cti)

      assert length(encoded) == 1
    end

    test "encodes all-nil struct to empty list" do
      assert CTI.encode(%CTI{}) == []
    end
  end

  describe "typed parsing integration" do
    test "message with CTI parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ORM^O01|1|P|2.5.1\r" <>
          "CTI|STUDY001^SPONSOR|P2^Phase 2|TP3^Visit 3\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      cti = Enum.find(msg.segments, &is_struct(&1, CTI))
      assert %CTI{} = cti
      assert cti.sponsor_study_id.entity_identifier == "STUDY001"
      assert cti.study_phase_identifier.identifier == "P2"
      assert cti.study_scheduled_time_point.identifier == "TP3"
    end
  end
end
