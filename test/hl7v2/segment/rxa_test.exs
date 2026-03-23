defmodule HL7v2.Segment.RXATest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.RXA
  alias HL7v2.Type.{CE, CWE, NM, TS, XCN, FN}

  describe "fields/0" do
    test "returns 26 field definitions" do
      assert length(RXA.fields()) == 26
    end
  end

  describe "segment_id/0" do
    test "returns RXA" do
      assert RXA.segment_id() == "RXA"
    end
  end

  describe "parse/1" do
    test "parses give_sub_id_counter and administration_sub_id_counter" do
      raw = ["0", "1"]

      result = RXA.parse(raw)

      assert %RXA{} = result
      assert %NM{value: "0"} = result.give_sub_id_counter
      assert %NM{value: "1"} = result.administration_sub_id_counter
    end

    test "parses date_time_start and end of administration" do
      raw = ["0", "1", ["20260322100000"], ["20260322101500"]]

      result = RXA.parse(raw)

      assert %TS{time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22, hour: 10, minute: 0}} =
               result.date_time_start_of_administration

      assert %TS{time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22, hour: 10, minute: 15}} =
               result.date_time_end_of_administration
    end

    test "parses administered_code and administered_amount" do
      raw = ["0", "1", "", "", ["VAC001", "COVID-19 Vaccine", "CVX"], "0.5"]

      result = RXA.parse(raw)

      assert %CE{identifier: "VAC001", text: "COVID-19 Vaccine"} = result.administered_code
      assert %NM{value: "0.5"} = result.administered_amount
    end

    test "parses administered_units and administered_dosage_form" do
      raw = ["0", "1", "", "", ["VAC001"], "0.5", ["mL", "milliliter"], ["INJ", "Injection"]]

      result = RXA.parse(raw)

      assert %CE{identifier: "mL"} = result.administered_units
      assert %CE{identifier: "INJ"} = result.administered_dosage_form
    end

    test "parses administration_notes as repeating CE" do
      raw = List.duplicate("", 8) ++ [[["NOTE1", "First dose"], ["NOTE2", "Left deltoid"]]]

      result = RXA.parse(raw)

      assert [%CE{identifier: "NOTE1"}, %CE{identifier: "NOTE2"}] = result.administration_notes
    end

    test "parses administering_provider as repeating XCN" do
      raw = List.duplicate("", 9) ++ [["NRS001", "Smith"]]

      result = RXA.parse(raw)

      assert [%XCN{id_number: "NRS001", family_name: %FN{surname: "Smith"}}] =
               result.administering_provider
    end

    test "parses administered_at_location as raw" do
      raw = List.duplicate("", 10) ++ [["CLINIC", "ROOM-A"]]

      result = RXA.parse(raw)

      assert result.administered_at_location == ["CLINIC", "ROOM-A"]
    end

    test "parses administered_per_time_unit and strength" do
      raw = List.duplicate("", 11) ++ ["H1", "500", ["mg", "milligram"]]

      result = RXA.parse(raw)

      assert result.administered_per_time_unit == "H1"
      assert %NM{value: "500"} = result.administered_strength
      assert %CE{identifier: "mg"} = result.administered_strength_units
    end

    test "parses substance_lot_number as repeating ST" do
      raw = List.duplicate("", 14) ++ [["LOT001", "LOT002"]]

      result = RXA.parse(raw)

      assert ["LOT001", "LOT002"] = result.substance_lot_number
    end

    test "parses substance_expiration_date as repeating TS" do
      raw = List.duplicate("", 15) ++ [[["20270101"], ["20270601"]]]

      result = RXA.parse(raw)

      assert [
               %TS{time: %HL7v2.Type.DTM{year: 2027, month: 1}},
               %TS{time: %HL7v2.Type.DTM{year: 2027, month: 6}}
             ] =
               result.substance_expiration_date
    end

    test "parses substance_manufacturer_name as repeating CE" do
      raw = List.duplicate("", 16) ++ [[["PFE", "Pfizer", "MVX"]]]

      result = RXA.parse(raw)

      assert [%CE{identifier: "PFE", text: "Pfizer"}] = result.substance_manufacturer_name
    end

    test "parses completion_status and action_code" do
      raw = List.duplicate("", 19) ++ ["CP", "A"]

      result = RXA.parse(raw)

      assert result.completion_status == "CP"
      assert result.action_code == "A"
    end

    test "parses system_entry_date_time" do
      raw = List.duplicate("", 21) ++ [["20260322103000"]]

      result = RXA.parse(raw)

      assert %TS{time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22, hour: 10, minute: 30}} =
               result.system_entry_date_time
    end

    test "parses administered_drug_strength_volume and units" do
      raw = List.duplicate("", 22) ++ ["50", ["mL", "milliliter", "ISO+"]]

      result = RXA.parse(raw)

      assert %NM{value: "50"} = result.administered_drug_strength_volume
      assert %CWE{identifier: "mL"} = result.administered_drug_strength_volume_units
    end

    test "parses administered_barcode_identifier" do
      raw = List.duplicate("", 24) ++ [["BC123", "Barcode"]]

      result = RXA.parse(raw)

      assert %CWE{identifier: "BC123"} = result.administered_barcode_identifier
    end

    test "parses pharmacy_order_type" do
      raw = List.duplicate("", 25) ++ ["M"]

      result = RXA.parse(raw)

      assert result.pharmacy_order_type == "M"
    end

    test "parses empty list -- all fields nil" do
      result = RXA.parse([])

      assert %RXA{} = result
      assert result.give_sub_id_counter == nil
      assert result.administered_code == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [
        "0",
        "1",
        ["20260322100000"],
        ["20260322101500"],
        ["VAC001", "COVID-19 Vaccine"],
        "0.5",
        ["mL", "milliliter"]
      ]

      encoded = raw |> RXA.parse() |> RXA.encode()
      reparsed = RXA.parse(encoded)

      assert %NM{value: "0"} = reparsed.give_sub_id_counter
      assert %NM{value: "1"} = reparsed.administration_sub_id_counter
      assert reparsed.administered_code.identifier == "VAC001"
      assert %NM{value: "0.5"} = reparsed.administered_amount
    end

    test "trailing nil fields trimmed" do
      rxa = %RXA{
        give_sub_id_counter: %NM{value: "0", original: "0"},
        administration_sub_id_counter: %NM{value: "1", original: "1"}
      }

      encoded = RXA.encode(rxa)

      assert length(encoded) == 2
    end

    test "encodes all-nil struct to empty list" do
      assert RXA.encode(%RXA{}) == []
    end
  end

  describe "typed parsing integration" do
    test "message with RXA parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||VXU^V04|1|P|2.5.1\r" <>
          "RXA|0|1|20260322100000||VAC001^COVID-19 Vaccine|0.5|mL^milliliter\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      rxa = Enum.find(msg.segments, &is_struct(&1, RXA))

      assert %RXA{
               give_sub_id_counter: %NM{value: "0"},
               administered_code: %CE{identifier: "VAC001"}
             } = rxa
    end
  end
end
