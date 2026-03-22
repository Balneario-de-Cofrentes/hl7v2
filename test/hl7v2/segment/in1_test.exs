defmodule HL7v2.Segment.IN1Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.IN1
  alias HL7v2.Type.{CE, CX, HD, XPN, FN}

  describe "field count" do
    test "defines 53 fields" do
      assert length(IN1.fields()) == 53
    end
  end

  describe "parse/1" do
    test "parses insurance info" do
      raw = [
        "1",
        ["BCBS", "Blue Cross Blue Shield"],
        ["INS001", "", "", "BCBS", "PI"]
      ]

      in1 = IN1.parse(raw)

      assert in1.set_id == 1
      assert %CE{identifier: "BCBS", text: "Blue Cross Blue Shield"} = in1.insurance_plan_id

      assert [
               %CX{
                 id: "INS001",
                 assigning_authority: %HD{namespace_id: "BCBS"},
                 identifier_type_code: "PI"
               }
             ] =
               in1.insurance_company_id
    end

    test "parses repeating insurance_company_id" do
      raw = [
        "1",
        ["BCBS", "Blue Cross Blue Shield"],
        [["INS001", "", "", "BCBS", "PI"], ["INS002", "", "", "AETNA", "PI"]]
      ]

      in1 = IN1.parse(raw)

      assert [
               %CX{id: "INS001", assigning_authority: %HD{namespace_id: "BCBS"}},
               %CX{id: "INS002", assigning_authority: %HD{namespace_id: "AETNA"}}
             ] = in1.insurance_company_id
    end

    test "parses name of insured" do
      # name_of_insured is at seq 16
      raw = List.duplicate(nil, 15) ++ [["Doe", "John"]]

      in1 = IN1.parse(raw)

      assert [%XPN{family_name: %FN{surname: "Doe"}, given_name: "John"}] = in1.name_of_insured
    end

    test "returns nil for missing optional fields" do
      in1 = IN1.parse(["1"])

      assert in1.set_id == 1
      assert in1.insurance_plan_id == nil
      assert in1.insurance_company_id == nil
      assert in1.group_number == nil
    end

    test "parses empty list" do
      in1 = IN1.parse([])

      assert in1.set_id == nil
      assert in1.insurance_plan_id == nil
    end
  end

  describe "encode/1" do
    test "encodes IN1 with insurance info" do
      in1 = %IN1{
        set_id: 1,
        insurance_plan_id: %CE{identifier: "BCBS", text: "Blue Cross Blue Shield"},
        insurance_company_id: [
          %CX{
            id: "INS001",
            assigning_authority: %HD{namespace_id: "BCBS"},
            identifier_type_code: "PI"
          }
        ]
      }

      encoded = IN1.encode(in1)

      assert Enum.at(encoded, 0) == "1"
      assert Enum.at(encoded, 1) == ["BCBS", "Blue Cross Blue Shield"]
      assert Enum.at(encoded, 2) == ["INS001", "", "", "BCBS", "PI"]
    end

    test "encodes nil segment fields" do
      in1 = %IN1{set_id: 1}
      encoded = IN1.encode(in1)

      assert encoded == ["1"]
    end
  end

  describe "round-trip" do
    test "parse then encode preserves insurance data" do
      raw = [
        "1",
        ["BCBS", "Blue Cross Blue Shield"],
        ["INS001", "", "", "BCBS", "PI"]
      ]

      result = raw |> IN1.parse() |> IN1.encode()

      assert Enum.at(result, 0) == "1"
      assert Enum.at(result, 1) == ["BCBS", "Blue Cross Blue Shield"]
      assert Enum.at(result, 2) == ["INS001", "", "", "BCBS", "PI"]
    end
  end
end
