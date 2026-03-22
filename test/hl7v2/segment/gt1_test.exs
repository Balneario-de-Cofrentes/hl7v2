defmodule HL7v2.Segment.GT1Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.GT1
  alias HL7v2.Type.{CE, CX, DTM, FN, HD, SAD, TS, XAD, XPN, XTN}

  describe "field count" do
    test "defines 55 fields" do
      assert length(GT1.fields()) == 55
    end
  end

  describe "parse/1" do
    test "parses guarantor info" do
      raw = [
        "1",
        ["G12345", "", "", "GID", "GI"],
        ["Smith", "Robert"],
        nil,
        ["456 Oak Ave", "", "Chicago", "IL", "60601"]
      ]

      gt1 = GT1.parse(raw)

      assert gt1.set_id == 1

      assert [
               %CX{
                 id: "G12345",
                 assigning_authority: %HD{namespace_id: "GID"},
                 identifier_type_code: "GI"
               }
             ] =
               gt1.guarantor_number

      assert [%XPN{family_name: %FN{surname: "Smith"}, given_name: "Robert"}] = gt1.guarantor_name

      assert [
               %XAD{
                 street_address: %SAD{street_or_mailing_address: "456 Oak Ave"},
                 city: "Chicago",
                 state: "IL"
               }
             ] =
               gt1.guarantor_address
    end

    test "parses repeating guarantor name" do
      raw = [
        "1",
        nil,
        [["Smith", "Robert"], ["Doe", "Robert"]]
      ]

      gt1 = GT1.parse(raw)

      assert [
               %XPN{family_name: %FN{surname: "Smith"}, given_name: "Robert"},
               %XPN{family_name: %FN{surname: "Doe"}, given_name: "Robert"}
             ] = gt1.guarantor_name
    end

    test "parses guarantor phone and date of birth" do
      raw = [
        "1",
        nil,
        ["Smith", "Robert"],
        nil,
        nil,
        ["", "PRN", "PH", "", "1", "312", "5551234"],
        nil,
        ["19700115"]
      ]

      gt1 = GT1.parse(raw)

      assert [%XTN{telecom_use_code: "PRN", area_code: "312", local_number: "5551234"}] =
               gt1.guarantor_ph_num_home

      assert %TS{time: %DTM{year: 1970, month: 1, day: 15}} = gt1.guarantor_date_time_of_birth
    end

    test "parses guarantor relationship" do
      # guarantor_relationship is at seq 11
      raw = List.duplicate(nil, 10) ++ [["SEL", "Self"]]

      gt1 = GT1.parse(raw)

      assert %CE{identifier: "SEL", text: "Self"} = gt1.guarantor_relationship
    end

    test "returns nil for missing optional fields" do
      gt1 = GT1.parse(["1", nil, ["Smith", "John"]])

      assert gt1.set_id == 1
      assert gt1.guarantor_number == nil
      assert gt1.guarantor_address == nil
      assert gt1.guarantor_ph_num_home == nil
    end

    test "parses empty list" do
      gt1 = GT1.parse([])

      assert gt1.set_id == nil
      assert gt1.guarantor_name == nil
    end
  end

  describe "encode/1" do
    test "encodes GT1 with guarantor info" do
      gt1 = %GT1{
        set_id: 1,
        guarantor_name: [%XPN{family_name: %FN{surname: "Smith"}, given_name: "Robert"}],
        guarantor_address: [
          %XAD{
            street_address: %SAD{street_or_mailing_address: "456 Oak Ave"},
            city: "Chicago",
            state: "IL",
            zip: "60601"
          }
        ]
      }

      encoded = GT1.encode(gt1)

      assert Enum.at(encoded, 0) == "1"
      assert Enum.at(encoded, 2) == ["Smith", "Robert"]
      assert Enum.at(encoded, 4) == ["456 Oak Ave", "", "Chicago", "IL", "60601"]
    end

    test "encodes nil segment fields" do
      gt1 = %GT1{set_id: 1, guarantor_name: [%XPN{family_name: %FN{surname: "Doe"}}]}
      encoded = GT1.encode(gt1)

      assert Enum.at(encoded, 0) == "1"
      assert Enum.at(encoded, 2) == ["Doe"]
    end
  end

  describe "round-trip" do
    test "parse then encode preserves guarantor data" do
      raw = [
        "1",
        nil,
        ["Smith", "Robert"],
        nil,
        ["456 Oak Ave", "", "Chicago", "IL", "60601"]
      ]

      result = raw |> GT1.parse() |> GT1.encode()

      assert Enum.at(result, 0) == "1"
      assert Enum.at(result, 2) == ["Smith", "Robert"]
      assert Enum.at(result, 4) == ["456 Oak Ave", "", "Chicago", "IL", "60601"]
    end
  end
end
