defmodule HL7v2.Segment.NK1Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.NK1
  alias HL7v2.Type.{CE, FN, XAD, XPN, XTN, SAD}

  describe "field count" do
    test "defines 39 fields" do
      assert length(NK1.fields()) == 39
    end
  end

  describe "parse/1" do
    test "parses set_id, name, and relationship" do
      raw = [
        "1",
        ["Smith", "Jane"],
        ["SPO", "Spouse"]
      ]

      nk1 = NK1.parse(raw)

      assert nk1.set_id == 1
      assert [%XPN{family_name: %FN{surname: "Smith"}, given_name: "Jane"}] = nk1.nk_name
      assert %CE{identifier: "SPO", text: "Spouse"} = nk1.relationship
    end

    test "parses repeating name field with multiple repetitions" do
      raw = [
        "1",
        [["Smith", "Jane"], ["Doe", "Jane"]],
        ["SPO", "Spouse"]
      ]

      nk1 = NK1.parse(raw)

      assert [
               %XPN{family_name: %FN{surname: "Smith"}, given_name: "Jane"},
               %XPN{family_name: %FN{surname: "Doe"}, given_name: "Jane"}
             ] = nk1.nk_name
    end

    test "parses address field" do
      raw = [
        "1",
        ["Smith", "Jane"],
        ["SPO", "Spouse"],
        ["123 Main St", "", "Springfield", "IL", "62704"]
      ]

      nk1 = NK1.parse(raw)

      assert [
               %XAD{
                 street_address: %SAD{street_or_mailing_address: "123 Main St"},
                 city: "Springfield"
               }
             ] =
               nk1.address
    end

    test "parses phone number field" do
      raw = [
        "1",
        ["Smith", "Jane"],
        nil,
        nil,
        ["", "PRN", "PH", "", "1", "555", "1234567"]
      ]

      nk1 = NK1.parse(raw)

      assert [%XTN{telecom_use_code: "PRN", telecom_equipment_type: "PH", area_code: "555"}] =
               nk1.phone_number
    end

    test "returns nil for missing optional fields" do
      nk1 = NK1.parse(["1"])

      assert nk1.set_id == 1
      assert nk1.nk_name == nil
      assert nk1.relationship == nil
      assert nk1.address == nil
      assert nk1.phone_number == nil
      assert nk1.business_phone_number == nil
    end

    test "parses empty list" do
      nk1 = NK1.parse([])

      assert nk1.set_id == nil
      assert nk1.nk_name == nil
    end
  end

  describe "encode/1" do
    test "encodes basic NK1" do
      nk1 = %NK1{
        set_id: 1,
        nk_name: [%XPN{family_name: %FN{surname: "Smith"}, given_name: "Jane"}],
        relationship: %CE{identifier: "SPO", text: "Spouse"}
      }

      encoded = NK1.encode(nk1)

      assert Enum.at(encoded, 0) == "1"
      assert Enum.at(encoded, 1) == ["Smith", "Jane"]
      assert Enum.at(encoded, 2) == ["SPO", "Spouse"]
    end

    test "encodes nil segment fields as empty strings" do
      nk1 = %NK1{set_id: 1}
      encoded = NK1.encode(nk1)

      assert encoded == ["1"]
    end
  end

  describe "round-trip" do
    test "parse then encode preserves data" do
      raw = [
        "1",
        ["Smith", "Jane"],
        ["SPO", "Spouse"]
      ]

      result = raw |> NK1.parse() |> NK1.encode()

      assert Enum.at(result, 0) == "1"
      assert Enum.at(result, 1) == ["Smith", "Jane"]
      assert Enum.at(result, 2) == ["SPO", "Spouse"]
    end
  end
end
