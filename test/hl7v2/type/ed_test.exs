defmodule HL7v2.Type.EDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.ED
  alias HL7v2.Type.HD

  doctest ED

  describe "parse/1" do
    test "parses full ED with source application" do
      result = ED.parse(["LAB&1.2.3&ISO", "Application", "PDF", "Base64", "JVBER..."])

      assert %HD{namespace_id: "LAB", universal_id: "1.2.3", universal_id_type: "ISO"} =
               result.source_application

      assert result.type_of_data == "Application"
      assert result.data_subtype == "PDF"
      assert result.encoding == "Base64"
      assert result.data == "JVBER..."
    end

    test "parses ED without source application" do
      result = ED.parse(["", "TEXT", "plain", "A", "Hello world"])
      assert result.source_application == nil
      assert result.type_of_data == "TEXT"
      assert result.data_subtype == "plain"
      assert result.encoding == "A"
      assert result.data == "Hello world"
    end

    test "parses DICOM image reference" do
      result = ED.parse(["PACS&2.16.840.1&ISO", "Image", "DICOM", "Base64", "encoded_data"])

      assert %HD{namespace_id: "PACS"} = result.source_application
      assert result.type_of_data == "Image"
      assert result.data_subtype == "DICOM"
      assert result.encoding == "Base64"
    end

    test "parses minimal ED with only type and data" do
      result = ED.parse(["", "Application", "PDF", "", "data"])
      assert result.source_application == nil
      assert result.type_of_data == "Application"
      assert result.data_subtype == "PDF"
      assert result.encoding == nil
      assert result.data == "data"
    end

    test "parses empty list" do
      result = ED.parse([])
      assert result.source_application == nil
      assert result.type_of_data == nil
      assert result.data_subtype == nil
      assert result.encoding == nil
      assert result.data == nil
    end
  end

  describe "encode/1" do
    test "encodes full ED" do
      ed = %ED{
        source_application: %HD{
          namespace_id: "LAB",
          universal_id: "1.2.3",
          universal_id_type: "ISO"
        },
        type_of_data: "Application",
        data_subtype: "PDF",
        encoding: "Base64",
        data: "JVBER..."
      }

      assert ED.encode(ed) == ["LAB&1.2.3&ISO", "Application", "PDF", "Base64", "JVBER..."]
    end

    test "encodes ED without source application" do
      ed = %ED{
        type_of_data: "TEXT",
        data_subtype: "plain",
        encoding: "A",
        data: "Hello"
      }

      assert ED.encode(ed) == ["", "TEXT", "plain", "A", "Hello"]
    end

    test "encodes ED with only type" do
      ed = %ED{type_of_data: "Application"}
      assert ED.encode(ed) == ["", "Application"]
    end

    test "encodes nil" do
      assert ED.encode(nil) == []
    end

    test "encodes empty struct" do
      assert ED.encode(%ED{}) == []
    end
  end

  describe "round-trip" do
    test "full ED round-trips" do
      components = ["LAB&1.2.3&ISO", "Application", "PDF", "Base64", "JVBER..."]
      assert components |> ED.parse() |> ED.encode() == components
    end

    test "ED without source round-trips" do
      components = ["", "TEXT", "plain", "A", "Hello"]
      assert components |> ED.parse() |> ED.encode() == components
    end
  end
end
