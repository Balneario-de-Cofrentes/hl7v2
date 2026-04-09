defmodule HL7v2.Segment.VNDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.VND
  alias HL7v2.Validation.FieldRules

  describe "fields/0" do
    test "returns 10 field definitions" do
      assert length(VND.fields()) == 10
    end
  end

  describe "segment_id/0" do
    test "returns VND" do
      assert VND.segment_id() == "VND"
    end
  end

  describe "parse/1" do
    test "parses set_id and vendor_identifier required fields" do
      raw = [
        ["1"],
        ["V001"],
        "Acme Medical",
        "CAT-123",
        ["P", "Primary"],
        [["Acme Corp"]],
        [["5678", "Doe", "John"]],
        ["CONTRACT-1"],
        [["FDA"]],
        ["H", "High"]
      ]

      result = VND.parse(raw)

      assert %VND{} = result
      assert %HL7v2.Type.EI{entity_identifier: "1"} = result.set_id
      assert %HL7v2.Type.EI{entity_identifier: "V001"} = result.vendor_identifier
      assert result.vendor_name == "Acme Medical"
      assert result.vendor_catalog_number == "CAT-123"

      assert %HL7v2.Type.CWE{identifier: "P", text: "Primary"} =
               result.primary_vendor_indicator
    end

    test "parses corporation as repeating XON" do
      raw = [
        ["1"],
        ["V001"],
        "",
        "",
        "",
        [["Acme Corp"], ["Beta Holdings"]]
      ]

      result = VND.parse(raw)

      assert [
               %HL7v2.Type.XON{organization_name: "Acme Corp"},
               %HL7v2.Type.XON{organization_name: "Beta Holdings"}
             ] = result.corporation
    end

    test "parses approving_regulatory_agency as repeating XON" do
      raw =
        List.duplicate("", 8) ++ [[["FDA"], ["CE"]]]

      result = VND.parse(raw)

      assert [
               %HL7v2.Type.XON{organization_name: "FDA"},
               %HL7v2.Type.XON{organization_name: "CE"}
             ] = result.approving_regulatory_agency
    end

    test "parses empty list — all fields nil" do
      result = VND.parse([])

      assert %VND{} = result
      assert result.set_id == nil
      assert result.vendor_identifier == nil
      assert result.vendor_name == nil
    end
  end

  describe "encode/1 round-trip" do
    test "preserves all fields through parse → encode → parse" do
      raw = [
        ["1"],
        ["V001"],
        "Acme Medical",
        "CAT-123",
        ["P", "Primary"],
        [["Acme Corp"]],
        ["5678", "Doe", "John"],
        ["CONTRACT-1"],
        [["FDA"]],
        ["H", "High"]
      ]

      parsed = VND.parse(raw)
      encoded = VND.encode(parsed)
      reparsed = VND.parse(encoded)

      assert reparsed.set_id.entity_identifier == "1"
      assert reparsed.vendor_identifier.entity_identifier == "V001"
      assert reparsed.vendor_name == "Acme Medical"
      assert reparsed.vendor_catalog_number == "CAT-123"
      assert reparsed.primary_vendor_indicator.identifier == "P"
      assert reparsed.primary_vendor_indicator.text == "Primary"
      assert [%HL7v2.Type.XON{organization_name: "Acme Corp"}] = reparsed.corporation
      assert %HL7v2.Type.XCN{id_number: "5678"} = reparsed.primary_contact

      assert [%HL7v2.Type.XON{organization_name: "FDA"}] =
               reparsed.approving_regulatory_agency

      assert reparsed.highest_level_of_concern_code.identifier == "H"
    end

    test "encodes all-nil struct to empty list" do
      assert VND.encode(%VND{}) == []
    end
  end

  describe "struct construction" do
    test "accepts keyword opts" do
      vnd = %VND{
        set_id: %HL7v2.Type.EI{entity_identifier: "1"},
        vendor_identifier: %HL7v2.Type.EI{entity_identifier: "V001"},
        vendor_name: "Acme Medical",
        corporation: [%HL7v2.Type.XON{organization_name: "Acme Corp"}]
      }

      assert vnd.set_id.entity_identifier == "1"
      assert vnd.vendor_identifier.entity_identifier == "V001"
      assert vnd.vendor_name == "Acme Medical"
      assert [%HL7v2.Type.XON{organization_name: "Acme Corp"}] = vnd.corporation
    end
  end

  describe "field validation" do
    test "missing required set_id fails typed parsing validation" do
      segment = %VND{
        set_id: nil,
        vendor_identifier: %HL7v2.Type.EI{entity_identifier: "V001"}
      }

      errors = FieldRules.check(segment)

      assert Enum.any?(errors, fn error ->
               error.level == :error and
                 error.location == "VND" and
                 error.field == :set_id
             end)
    end

    test "missing required vendor_identifier fails typed parsing validation" do
      segment = %VND{
        set_id: %HL7v2.Type.EI{entity_identifier: "1"},
        vendor_identifier: nil
      }

      errors = FieldRules.check(segment)

      assert Enum.any?(errors, fn error ->
               error.level == :error and
                 error.location == "VND" and
                 error.field == :vendor_identifier
             end)
    end

    test "both required fields populated passes field rules" do
      segment = %VND{
        set_id: %HL7v2.Type.EI{entity_identifier: "1"},
        vendor_identifier: %HL7v2.Type.EI{entity_identifier: "V001"}
      }

      errors = FieldRules.check(segment)

      refute Enum.any?(errors, &(&1.level == :error))
    end
  end

  describe "typed parsing integration" do
    test "parses VND wire line in a full message" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||OMI^O23|1|P|2.6\r" <>
          "VND|1|V001|Acme Medical\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      vnd = Enum.find(msg.segments, &is_struct(&1, VND))

      assert %VND{} = vnd
      assert vnd.set_id.entity_identifier == "1"
      assert vnd.vendor_identifier.entity_identifier == "V001"
      assert vnd.vendor_name == "Acme Medical"
    end
  end
end
