defmodule HL7v2.Segment.SFTTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.SFT

  describe "fields/0" do
    test "returns 6 field definitions" do
      assert length(SFT.fields()) == 6
    end
  end

  describe "segment_id/0" do
    test "returns SFT" do
      assert SFT.segment_id() == "SFT"
    end
  end

  describe "parse/1" do
    test "parses vendor organization as XON" do
      raw = [
        ["Acme Medical", "", "", "", "", "", "", "", ""],
        "1.2.3",
        "MedViewer",
        "BIN-42"
      ]

      result = SFT.parse(raw)

      assert %SFT{} = result
      assert %HL7v2.Type.XON{organization_name: "Acme Medical"} = result.software_vendor_organization
      assert result.software_certified_version_or_release_number == "1.2.3"
      assert result.software_product_name == "MedViewer"
      assert result.software_binary_id == "BIN-42"
    end

    test "parses product information as TX" do
      raw = [
        ["Acme Medical"],
        "1.0",
        "MedViewer",
        "BIN-1",
        "Additional product info text"
      ]

      result = SFT.parse(raw)

      assert result.software_product_information == "Additional product info text"
    end

    test "parses install date as TS" do
      raw = [
        ["Acme Medical"],
        "1.0",
        "MedViewer",
        "BIN-1",
        "",
        ["20260101120000"]
      ]

      result = SFT.parse(raw)

      assert %HL7v2.Type.TS{
               time: %HL7v2.Type.DTM{year: 2026, month: 1, day: 1, hour: 12}
             } = result.software_install_date
    end

    test "parses empty list — all fields nil" do
      result = SFT.parse([])

      assert %SFT{} = result
      assert result.software_vendor_organization == nil
      assert result.software_certified_version_or_release_number == nil
      assert result.software_product_name == nil
      assert result.software_binary_id == nil
      assert result.software_product_information == nil
      assert result.software_install_date == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [
        ["Acme Medical"],
        "1.2.3",
        "MedViewer",
        "BIN-42"
      ]

      encoded = raw |> SFT.parse() |> SFT.encode()

      assert Enum.at(encoded, 0) == ["Acme Medical"]
      assert Enum.at(encoded, 1) == "1.2.3"
      assert Enum.at(encoded, 2) == "MedViewer"
      assert Enum.at(encoded, 3) == "BIN-42"
    end

    test "trailing nil fields trimmed" do
      sft = %SFT{
        software_vendor_organization: %HL7v2.Type.XON{organization_name: "Acme"},
        software_certified_version_or_release_number: "1.0",
        software_product_name: "App",
        software_binary_id: "B1"
      }

      encoded = SFT.encode(sft)

      assert length(encoded) == 4
    end

    test "encodes all-nil struct to empty list" do
      assert SFT.encode(%SFT{}) == []
    end
  end

  describe "typed parsing integration" do
    test "ADT^A01 with SFT parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.5.1\r" <>
          "SFT|Acme Medical|1.0|MedViewer|BIN-1\r" <>
          "EVN|A01|20260322\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|I\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      sft = Enum.find(msg.segments, &is_struct(&1, SFT))
      assert %SFT{} = sft
      assert sft.software_product_name == "MedViewer"
    end
  end
end
