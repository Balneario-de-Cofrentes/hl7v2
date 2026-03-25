defmodule HL7v2.Segment.NSCTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.NSC

  describe "fields/0" do
    test "returns 9 field definitions" do
      assert length(NSC.fields()) == 9
    end
  end

  describe "segment_id/0" do
    test "returns NSC" do
      assert NSC.segment_id() == "NSC"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = NSC.parse([])
      assert %NSC{} = result
      assert result.application_change_type == nil
    end

    test "parses application change type and cpu fields" do
      raw = ["M", "CPU1", "FS1", ["APP1"], ["FAC1"], "CPU2", "FS2", ["APP2"], ["FAC2"]]
      result = NSC.parse(raw)

      assert result.application_change_type == "M"
      assert result.current_cpu == "CPU1"
      assert result.current_fileserver == "FS1"
      assert %HL7v2.Type.HD{namespace_id: "APP1"} = result.current_application
      assert %HL7v2.Type.HD{namespace_id: "FAC1"} = result.current_facility
      assert result.new_cpu == "CPU2"
      assert result.new_fileserver == "FS2"
      assert %HL7v2.Type.HD{namespace_id: "APP2"} = result.new_application
      assert %HL7v2.Type.HD{namespace_id: "FAC2"} = result.new_facility
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["M", "CPU1", "FS1"]
      encoded = raw |> NSC.parse() |> NSC.encode()
      reparsed = NSC.parse(encoded)
      assert reparsed.application_change_type == "M"
      assert reparsed.current_cpu == "CPU1"
    end

    test "encodes all-nil struct to empty list" do
      assert NSC.encode(%NSC{}) == []
    end
  end
end
