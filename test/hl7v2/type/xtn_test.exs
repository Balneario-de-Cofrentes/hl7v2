defmodule HL7v2.Type.XTNTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.XTN

  doctest XTN

  describe "parse/1" do
    test "parses phone with all components" do
      result =
        XTN.parse([
          "(555)555-1234",
          "PRN",
          "PH",
          "",
          "1",
          "555",
          "5551234",
          "789",
          "Home phone",
          "X",
          "001",
          "+15555551234"
        ])

      assert result.telephone_number == "(555)555-1234"
      assert result.telecom_use_code == "PRN"
      assert result.telecom_equipment_type == "PH"
      assert result.country_code == "1"
      assert result.area_code == "555"
      assert result.local_number == "5551234"
      assert result.extension == "789"
      assert result.any_text == "Home phone"
      assert result.extension_prefix == "X"
      assert result.speed_dial_code == "001"
      assert result.unformatted_telephone_number == "+15555551234"
    end

    test "parses email" do
      result = XTN.parse(["", "NET", "Internet", "john@example.com"])

      assert result.telecom_use_code == "NET"
      assert result.telecom_equipment_type == "Internet"
      assert result.email_address == "john@example.com"
    end

    test "parses empty list" do
      assert %XTN{} = XTN.parse([])
    end
  end

  describe "encode/1" do
    test "encodes nil returns empty list" do
      assert XTN.encode(nil) == []
    end

    test "encodes empty struct" do
      assert XTN.encode(%XTN{}) == []
    end

    test "encodes phone" do
      xtn = %XTN{
        telecom_use_code: "PRN",
        telecom_equipment_type: "PH",
        country_code: "1",
        area_code: "555",
        local_number: "5551234"
      }

      encoded = XTN.encode(xtn)
      assert Enum.at(encoded, 1) == "PRN"
      assert Enum.at(encoded, 2) == "PH"
      assert Enum.at(encoded, 4) == "1"
      assert Enum.at(encoded, 5) == "555"
      assert Enum.at(encoded, 6) == "5551234"
    end

    test "encodes email" do
      xtn = %XTN{
        telecom_use_code: "NET",
        telecom_equipment_type: "Internet",
        email_address: "john@example.com"
      }

      assert XTN.encode(xtn) == ["", "NET", "Internet", "john@example.com"]
    end

    test "encodes with unformatted telephone number at end" do
      xtn = %XTN{unformatted_telephone_number: "+15555551234"}

      encoded = XTN.encode(xtn)
      assert List.last(encoded) == "+15555551234"
    end

    test "encode round-trip" do
      original = %XTN{
        telecom_use_code: "PRN",
        telecom_equipment_type: "PH",
        country_code: "34",
        area_code: "961",
        local_number: "123456"
      }

      parsed = original |> XTN.encode() |> XTN.parse()
      assert parsed.telecom_use_code == "PRN"
      assert parsed.country_code == "34"
      assert parsed.local_number == "123456"
    end
  end
end
