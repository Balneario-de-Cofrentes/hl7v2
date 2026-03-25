defmodule HL7v2.Segment.MFITest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.MFI

  describe "fields/0" do
    test "returns 6 field definitions" do
      assert length(MFI.fields()) == 6
    end
  end

  describe "segment_id/0" do
    test "returns MFI" do
      assert MFI.segment_id() == "MFI"
    end
  end

  describe "parse/1" do
    test "parses master file identifier and event code" do
      raw = [["CDM", "Charge Description Master"], "", "UPD"]

      result = MFI.parse(raw)

      assert %MFI{} = result
      assert %HL7v2.Type.CE{identifier: "CDM"} = result.master_file_identifier
      assert result.file_level_event_code == "UPD"
    end

    test "parses response_level_code" do
      raw = [["CDM"], "", "UPD", "", "", "AL"]

      result = MFI.parse(raw)

      assert result.response_level_code == "AL"
    end

    test "parses empty list" do
      result = MFI.parse([])

      assert %MFI{} = result
      assert result.master_file_identifier == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert MFI.encode(%MFI{}) == []
    end

    test "round-trip preserves data" do
      raw = [["CDM", "Charge Description Master"], "", "UPD"]

      encoded = raw |> MFI.parse() |> MFI.encode()

      assert Enum.at(encoded, 0) == ["CDM", "Charge Description Master"]
      assert Enum.at(encoded, 2) == "UPD"
    end
  end
end
