defmodule HL7v2.Segment.RXGTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.RXG
  alias HL7v2.Type.{CE, CWE, NM}

  describe "fields/0" do
    test "returns 27 field definitions" do
      assert length(RXG.fields()) == 27
    end
  end

  describe "segment_id/0" do
    test "returns RXG" do
      assert RXG.segment_id() == "RXG"
    end
  end

  describe "parse/1" do
    test "parses give_sub_id_counter and dispense_sub_id_counter" do
      raw = ["1", "1"]

      result = RXG.parse(raw)

      assert %RXG{} = result
      assert %NM{value: "1"} = result.give_sub_id_counter
      assert %NM{value: "1"} = result.dispense_sub_id_counter
    end

    test "parses quantity_timing as TQ" do
      raw = ["1", "", ["1", "QD"]]

      result = RXG.parse(raw)

      assert %{quantity: %HL7v2.Type.CQ{quantity: "1"}, interval: "QD"} = result.quantity_timing
    end

    test "parses give_code, give_amount_minimum/maximum, give_units" do
      raw = ["1", "", "", ["RX001", "Amoxicillin"], "250", "500", ["mg", "milligram"]]

      result = RXG.parse(raw)

      assert %CE{identifier: "RX001"} = result.give_code
      assert %NM{value: "250"} = result.give_amount_minimum
      assert %NM{value: "500"} = result.give_amount_maximum
      assert %CE{identifier: "mg"} = result.give_units
    end

    test "parses give_dosage_form" do
      raw = List.duplicate("", 7) ++ [["TAB", "Tablet"]]

      result = RXG.parse(raw)

      assert %CE{identifier: "TAB"} = result.give_dosage_form
    end

    test "parses administration_notes as repeating CE" do
      raw = List.duplicate("", 8) ++ [[["NOTE1", "Take with food"], ["NOTE2", "After meals"]]]

      result = RXG.parse(raw)

      assert [%CE{identifier: "NOTE1"}, %CE{identifier: "NOTE2"}] = result.administration_notes
    end

    test "parses substitution_status" do
      raw = List.duplicate("", 9) ++ ["G"]

      result = RXG.parse(raw)

      assert result.substitution_status == "G"
    end

    test "parses dispense_to_location as LA1" do
      raw = List.duplicate("", 10) ++ [["LOC1", "WARD-A"]]

      result = RXG.parse(raw)

      assert %HL7v2.Type.LA1{point_of_care: "LOC1", room: "WARD-A"} =
               result.dispense_to_location
    end

    test "parses needs_human_review" do
      raw = List.duplicate("", 11) ++ ["Y"]

      result = RXG.parse(raw)

      assert result.needs_human_review == "Y"
    end

    test "parses give_per_time_unit and give_strength" do
      raw = List.duplicate("", 13) ++ ["H1", "500", ["mg", "milligram"]]

      result = RXG.parse(raw)

      assert result.give_per_time_unit == "H1"
      assert %NM{value: "500"} = result.give_strength
      assert %CE{identifier: "mg"} = result.give_strength_units
    end

    test "parses substance_lot_number as repeating ST" do
      raw = List.duplicate("", 16) ++ [["LOT001", "LOT002"]]

      result = RXG.parse(raw)

      assert ["LOT001", "LOT002"] = result.substance_lot_number
    end

    test "parses indication as repeating CE" do
      raw = List.duplicate("", 19) ++ [[["IND1", "Pain"], ["IND2", "Inflammation"]]]

      result = RXG.parse(raw)

      assert [%CE{identifier: "IND1"}, %CE{identifier: "IND2"}] = result.indication
    end

    test "parses give_drug_strength_volume and units" do
      raw = List.duplicate("", 20) ++ ["50", ["mL", "milliliter", "ISO+"]]

      result = RXG.parse(raw)

      assert %NM{value: "50"} = result.give_drug_strength_volume
      assert %CWE{identifier: "mL"} = result.give_drug_strength_volume_units
    end

    test "parses give_barcode_identifier and pharmacy_order_type" do
      raw = List.duplicate("", 22) ++ [["BC123", "Barcode"], "M"]

      result = RXG.parse(raw)

      assert %CWE{identifier: "BC123"} = result.give_barcode_identifier
      assert result.pharmacy_order_type == "M"
    end

    test "parses dispense_to_pharmacy and deliver_to_patient_location" do
      raw = List.duplicate("", 24) ++ [["PHARM1", "Main Pharmacy"], "", ["ICU", "101"]]

      result = RXG.parse(raw)

      assert %CWE{identifier: "PHARM1"} = result.dispense_to_pharmacy

      assert %HL7v2.Type.PL{point_of_care: "ICU", room: "101"} =
               result.deliver_to_patient_location
    end

    test "parses empty list -- all fields nil" do
      result = RXG.parse([])

      assert %RXG{} = result
      assert result.give_sub_id_counter == nil
      assert result.give_code == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["1", "1", ["1", "QD"], ["RX001", "Amoxicillin"], "250", "", ["mg", "milligram"]]

      encoded = raw |> RXG.parse() |> RXG.encode()
      reparsed = RXG.parse(encoded)

      assert %NM{value: "1"} = reparsed.give_sub_id_counter
      assert reparsed.give_code.identifier == "RX001"
      assert %NM{value: "250"} = reparsed.give_amount_minimum
      assert reparsed.give_units.identifier == "mg"
    end

    test "typed fields 25-27 round-trip" do
      raw = List.duplicate("", 24) ++ [["PHARM1", "Main Pharmacy"]]

      encoded = raw |> RXG.parse() |> RXG.encode()
      reparsed = RXG.parse(encoded)

      assert %CWE{identifier: "PHARM1"} = reparsed.dispense_to_pharmacy
    end

    test "trailing nil fields trimmed" do
      rxg = %RXG{give_sub_id_counter: %NM{value: "1", original: "1"}}

      encoded = RXG.encode(rxg)

      assert length(encoded) == 1
    end

    test "encodes all-nil struct to empty list" do
      assert RXG.encode(%RXG{}) == []
    end
  end

  describe "typed parsing integration" do
    test "message with RXG parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||RGV^O15|1|P|2.5.1\r" <>
          "RXG|1|1||RX001^Amoxicillin|250||mg^milligram\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      rxg = Enum.find(msg.segments, &is_struct(&1, RXG))
      assert %RXG{give_sub_id_counter: %NM{value: "1"}} = rxg
      assert rxg.give_code.identifier == "RX001"
    end
  end
end
