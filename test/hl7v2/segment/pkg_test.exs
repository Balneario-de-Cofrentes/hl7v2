defmodule HL7v2.Segment.PKGTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.PKG
  alias HL7v2.Validation.FieldRules

  describe "fields/0" do
    test "returns 7 field definitions" do
      assert length(PKG.fields()) == 7
    end
  end

  describe "segment_id/0" do
    test "returns PKG" do
      assert PKG.segment_id() == "PKG"
    end
  end

  describe "parse/1" do
    test "parses set_id and packaging_units_code required fields" do
      raw = [
        "1",
        ["BX", "Box"],
        "Y",
        "12",
        ["25.00&USD", "UP"],
        ["27.50&USD", "UP"],
        "20260601000000"
      ]

      result = PKG.parse(raw)

      assert %PKG{} = result
      assert result.set_id == 1

      assert %HL7v2.Type.CWE{identifier: "BX", text: "Box"} =
               result.packaging_units_code

      assert result.default_order_unit_of_measure_indicator == "Y"
      assert %HL7v2.Type.NM{value: "12"} = result.package_quantity

      assert %HL7v2.Type.CP{
               price: %HL7v2.Type.MO{quantity: "25.00", denomination: "USD"},
               price_type: "UP"
             } = result.price

      assert %HL7v2.Type.CP{
               price: %HL7v2.Type.MO{quantity: "27.50", denomination: "USD"},
               price_type: "UP"
             } = result.future_item_price
    end

    test "parses empty list — all fields nil" do
      result = PKG.parse([])

      assert %PKG{} = result
      assert result.set_id == nil
      assert result.packaging_units_code == nil
      assert result.default_order_unit_of_measure_indicator == nil
      assert result.package_quantity == nil
      assert result.price == nil
      assert result.future_item_price == nil
      assert result.future_item_price_effective_date == nil
    end
  end

  describe "encode/1 round-trip" do
    test "preserves all fields through parse → encode → parse" do
      raw = [
        "1",
        ["BX", "Box"],
        "Y",
        "12",
        ["25.00&USD", "UP"],
        ["27.50&USD", "UP"],
        "20260601000000"
      ]

      parsed = PKG.parse(raw)
      encoded = PKG.encode(parsed)
      reparsed = PKG.parse(encoded)

      assert reparsed.set_id == 1
      assert reparsed.packaging_units_code.identifier == "BX"
      assert reparsed.packaging_units_code.text == "Box"
      assert reparsed.default_order_unit_of_measure_indicator == "Y"
      assert reparsed.package_quantity.value == "12"
      assert reparsed.price.price.quantity == "25.00"
      assert reparsed.price.price.denomination == "USD"
      assert reparsed.price.price_type == "UP"
      assert reparsed.future_item_price.price.quantity == "27.50"
      assert reparsed.future_item_price.price_type == "UP"
    end

    test "encodes all-nil struct to empty list" do
      assert PKG.encode(%PKG{}) == []
    end
  end

  describe "struct construction" do
    test "accepts keyword opts" do
      pkg = %PKG{
        set_id: 1,
        packaging_units_code: %HL7v2.Type.CWE{identifier: "BX", text: "Box"},
        default_order_unit_of_measure_indicator: "Y",
        package_quantity: "12",
        price: %HL7v2.Type.CP{
          price: %HL7v2.Type.MO{quantity: "25.00", denomination: "USD"},
          price_type: "UP"
        }
      }

      assert pkg.set_id == 1
      assert pkg.packaging_units_code.identifier == "BX"
      assert pkg.packaging_units_code.text == "Box"
      assert pkg.default_order_unit_of_measure_indicator == "Y"
      assert pkg.package_quantity == "12"
      assert pkg.price.price.quantity == "25.00"
      assert pkg.price.price_type == "UP"
    end
  end

  describe "field validation" do
    test "missing required set_id fails typed parsing validation" do
      segment = %PKG{
        set_id: nil,
        packaging_units_code: %HL7v2.Type.CWE{identifier: "BX"}
      }

      errors = FieldRules.check(segment)

      assert Enum.any?(errors, fn error ->
               error.level == :error and
                 error.location == "PKG" and
                 error.field == :set_id
             end)
    end

    test "missing required packaging_units_code fails typed parsing validation" do
      segment = %PKG{set_id: 1, packaging_units_code: nil}

      errors = FieldRules.check(segment)

      assert Enum.any?(errors, fn error ->
               error.level == :error and
                 error.location == "PKG" and
                 error.field == :packaging_units_code
             end)
    end

    test "both required fields populated passes field rules" do
      segment = %PKG{
        set_id: 1,
        packaging_units_code: %HL7v2.Type.CWE{identifier: "BX"}
      }

      errors = FieldRules.check(segment)

      refute Enum.any?(errors, &(&1.level == :error))
    end
  end

  describe "typed parsing integration" do
    test "parses PKG wire line in a full message" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.7\r" <>
          "EVN|A01|20260322\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|I\r" <>
          "PKG|1|BX^Box||12\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      pkg = Enum.find(msg.segments, &is_struct(&1, PKG))

      assert %PKG{set_id: 1} = pkg
      assert pkg.packaging_units_code.identifier == "BX"
      assert pkg.packaging_units_code.text == "Box"
      assert pkg.package_quantity.value == "12"
    end
  end
end
