defmodule HL7v2.Type.RPTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.RP
  alias HL7v2.Type.HD

  doctest RP

  describe "parse/1" do
    test "parses full RP with application ID" do
      result = RP.parse(["/reports/12345.pdf", "LAB&1.2.3&ISO", "Application", "PDF"])
      assert result.pointer == "/reports/12345.pdf"

      assert %HD{namespace_id: "LAB", universal_id: "1.2.3", universal_id_type: "ISO"} =
               result.application_id

      assert result.type_of_data == "Application"
      assert result.subtype == "PDF"
    end

    test "parses pointer only" do
      result = RP.parse(["http://example.com/image.jpg"])
      assert result.pointer == "http://example.com/image.jpg"
      assert result.application_id == nil
      assert result.type_of_data == nil
      assert result.subtype == nil
    end

    test "parses pointer with type but no application" do
      result = RP.parse(["/data/scan.dcm", "", "Image", "DICOM"])
      assert result.pointer == "/data/scan.dcm"
      assert result.application_id == nil
      assert result.type_of_data == "Image"
      assert result.subtype == "DICOM"
    end

    test "parses empty list" do
      result = RP.parse([])
      assert result.pointer == nil
      assert result.application_id == nil
      assert result.type_of_data == nil
      assert result.subtype == nil
    end
  end

  describe "encode/1" do
    test "encodes full RP" do
      rp = %RP{
        pointer: "/reports/12345.pdf",
        application_id: %HD{namespace_id: "LAB", universal_id: "1.2.3", universal_id_type: "ISO"},
        type_of_data: "Application",
        subtype: "PDF"
      }

      assert RP.encode(rp) == ["/reports/12345.pdf", "LAB&1.2.3&ISO", "Application", "PDF"]
    end

    test "encodes pointer only" do
      assert RP.encode(%RP{pointer: "/image.jpg"}) == ["/image.jpg"]
    end

    test "encodes pointer with type, no application" do
      rp = %RP{pointer: "/scan.dcm", type_of_data: "Image", subtype: "DICOM"}
      assert RP.encode(rp) == ["/scan.dcm", "", "Image", "DICOM"]
    end

    test "encodes nil" do
      assert RP.encode(nil) == []
    end

    test "encodes empty struct" do
      assert RP.encode(%RP{}) == []
    end
  end

  describe "round-trip" do
    test "full RP round-trips" do
      components = ["/reports/12345.pdf", "LAB&1.2.3&ISO", "Application", "PDF"]
      assert components |> RP.parse() |> RP.encode() == components
    end

    test "pointer-only round-trips" do
      components = ["/image.jpg"]
      assert components |> RP.parse() |> RP.encode() == components
    end

    test "pointer with type round-trips" do
      components = ["/scan.dcm", "", "Image", "DICOM"]
      assert components |> RP.parse() |> RP.encode() == components
    end
  end
end
