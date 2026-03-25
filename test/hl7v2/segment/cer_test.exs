defmodule HL7v2.Segment.CERTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.CER

  describe "fields/0" do
    test "returns 31 field definitions" do
      assert length(CER.fields()) == 31
    end
  end

  describe "segment_id/0" do
    test "returns CER" do
      assert CER.segment_id() == "CER"
    end
  end

  describe "parse/1" do
    test "parses empty list" do
      result = CER.parse([])
      assert %CER{} = result
      assert result.set_id == nil
      assert result.serial_number == nil
    end

    test "parses certificate detail typed fields" do
      raw = [
        "1",
        "SN12345",
        "3",
        nil,
        nil,
        nil,
        "US",
        nil,
        nil,
        ["X509", "X.509 Certificate", "CERT_TYPES"],
        nil,
        ["CERT001", "NS1"],
        "John Doe, MD"
      ]

      result = CER.parse(raw)
      assert result.set_id == 1
      assert result.serial_number == "SN12345"
      assert result.version == "3"
      assert result.granting_country == "US"
      assert %HL7v2.Type.CWE{identifier: "X509"} = result.certificate_type
      assert %HL7v2.Type.EI{entity_identifier: "CERT001"} = result.subject_id
      assert result.subject_name == "John Doe, MD"
    end

    test "preserves raw trailing fields" do
      raw = List.duplicate(nil, 20) ++ ["raw_field_21"]
      result = CER.parse(raw)
      assert result.field_21 == "raw_field_21"
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["1", "SN12345", "3"]
      encoded = raw |> CER.parse() |> CER.encode()
      reparsed = CER.parse(encoded)
      assert reparsed.set_id == 1
      assert reparsed.serial_number == "SN12345"
    end

    test "encodes all-nil struct to empty list" do
      assert CER.encode(%CER{}) == []
    end
  end
end
