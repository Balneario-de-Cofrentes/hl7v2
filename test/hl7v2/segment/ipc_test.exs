defmodule HL7v2.Segment.IPCTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.IPC

  describe "fields/0" do
    test "returns 9 field definitions" do
      assert length(IPC.fields()) == 9
    end
  end

  describe "segment_id/0" do
    test "returns IPC" do
      assert IPC.segment_id() == "IPC"
    end
  end

  describe "parse/1" do
    test "parses accession and procedure IDs" do
      raw = [
        ["ACC001", "RIS"],
        ["RP001", "RIS"],
        ["1.2.3.4.5", ""],
        ["SPS001", "RIS"]
      ]

      result = IPC.parse(raw)

      assert %IPC{} = result
      assert %HL7v2.Type.EI{entity_identifier: "ACC001"} = result.accession_identifier
      assert %HL7v2.Type.EI{entity_identifier: "RP001"} = result.requested_procedure_id
      assert %HL7v2.Type.EI{entity_identifier: "1.2.3.4.5"} = result.study_instance_uid
      assert %HL7v2.Type.EI{entity_identifier: "SPS001"} = result.scheduled_procedure_step_id
    end

    test "parses modality as CE" do
      raw = List.duplicate("", 4) ++ [["CT", "Computed Tomography"]]

      result = IPC.parse(raw)

      assert %HL7v2.Type.CE{identifier: "CT"} = result.modality
    end

    test "parses scheduled_ae_title as ST" do
      raw = List.duplicate("", 8) ++ ["AE_TITLE_1"]

      result = IPC.parse(raw)

      assert result.scheduled_ae_title == "AE_TITLE_1"
    end

    test "parses empty list" do
      result = IPC.parse([])

      assert %IPC{} = result
      assert result.accession_identifier == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert IPC.encode(%IPC{}) == []
    end

    test "round-trip preserves data" do
      raw = [["ACC001", "RIS"], ["RP001", "RIS"]]

      encoded = raw |> IPC.parse() |> IPC.encode()

      assert Enum.at(encoded, 0) == ["ACC001", "RIS"]
      assert Enum.at(encoded, 1) == ["RP001", "RIS"]
    end
  end
end
