defmodule HL7v2.Segment.RXDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.RXD
  alias HL7v2.Type.{CE, CQ, DTM, NM, TS, XCN, FN}

  describe "fields/0" do
    test "returns 33 field definitions" do
      assert length(RXD.fields()) == 33
    end
  end

  describe "segment_id/0" do
    test "returns RXD" do
      assert RXD.segment_id() == "RXD"
    end
  end

  describe "parse/1" do
    test "parses dispense_sub_id_counter and dispense_give_code" do
      raw = ["1", ["RX001", "Amoxicillin", "NDC"]]

      result = RXD.parse(raw)

      assert %RXD{} = result
      assert %NM{value: "1"} = result.dispense_sub_id_counter
      assert %CE{identifier: "RX001", text: "Amoxicillin"} = result.dispense_give_code
    end

    test "parses date_time_dispensed as TS" do
      raw = ["1", ["RX001"], ["20260322140000"]]

      result = RXD.parse(raw)

      assert %TS{time: %DTM{year: 2026, month: 3, day: 22, hour: 14}} =
               result.date_time_dispensed
    end

    test "parses actual_dispense_amount and units" do
      raw = ["1", ["RX001"], "", "30", ["TAB", "Tablet"]]

      result = RXD.parse(raw)

      assert %NM{value: "30"} = result.actual_dispense_amount
      assert %CE{identifier: "TAB"} = result.actual_dispense_units
    end

    test "parses prescription_number and number_of_refills_remaining" do
      raw = List.duplicate("", 6) ++ ["RX12345", "2"]

      result = RXD.parse(raw)

      assert result.prescription_number == "RX12345"
      assert %NM{value: "2"} = result.number_of_refills_remaining
    end

    test "parses dispensing_provider as repeating XCN" do
      raw = List.duplicate("", 9) ++ [["PHAR001", "Jones"]]

      result = RXD.parse(raw)

      assert [%XCN{id_number: "PHAR001", family_name: %FN{surname: "Jones"}}] =
               result.dispensing_provider
    end

    test "parses substitution_status and total_daily_dose" do
      raw = List.duplicate("", 10) ++ ["G", ["1500", ["mg", "milligram"]]]

      result = RXD.parse(raw)

      assert result.substitution_status == "G"
      assert %CQ{quantity: "1500"} = result.total_daily_dose
    end

    test "parses dispense_to_location as raw" do
      raw = List.duplicate("", 12) ++ [["LOC1", "WARD-A"]]

      result = RXD.parse(raw)

      assert result.dispense_to_location == ["LOC1", "WARD-A"]
    end

    test "parses needs_human_review" do
      raw = List.duplicate("", 13) ++ ["Y"]

      result = RXD.parse(raw)

      assert result.needs_human_review == "Y"
    end

    test "parses actual_strength and actual_strength_unit" do
      raw = List.duplicate("", 15) ++ ["500", ["mg", "milligram"]]

      result = RXD.parse(raw)

      assert %NM{value: "500"} = result.actual_strength
      assert %CE{identifier: "mg"} = result.actual_strength_unit
    end

    test "parses substance_lot_number as repeating ST" do
      raw = List.duplicate("", 17) ++ [["LOT001", "LOT002"]]

      result = RXD.parse(raw)

      assert ["LOT001", "LOT002"] = result.substance_lot_number
    end

    test "preserves raw fields 21-33" do
      raw = List.duplicate("", 20) ++ ["raw21", "raw22"]

      result = RXD.parse(raw)

      assert result.field_21 == "raw21"
      assert result.field_22 == "raw22"
    end

    test "parses empty list -- all fields nil" do
      result = RXD.parse([])

      assert %RXD{} = result
      assert result.dispense_sub_id_counter == nil
      assert result.dispense_give_code == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["1", ["RX001", "Amoxicillin"], ["20260322"], "30", ["TAB", "Tablet"]]

      encoded = raw |> RXD.parse() |> RXD.encode()
      reparsed = RXD.parse(encoded)

      assert %NM{value: "1"} = reparsed.dispense_sub_id_counter
      assert reparsed.dispense_give_code.identifier == "RX001"
      assert %NM{value: "30"} = reparsed.actual_dispense_amount
    end

    test "trailing nil fields trimmed" do
      rxd = %RXD{dispense_sub_id_counter: %NM{value: "1", original: "1"}}

      encoded = RXD.encode(rxd)

      assert length(encoded) == 1
    end

    test "encodes all-nil struct to empty list" do
      assert RXD.encode(%RXD{}) == []
    end
  end

  describe "typed parsing integration" do
    test "message with RXD parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||RDS^O13|1|P|2.5.1\r" <>
          "RXD|1|RX001^Amoxicillin|20260322140000|30\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      rxd = Enum.find(msg.segments, &is_struct(&1, RXD))
      assert %RXD{dispense_sub_id_counter: %NM{value: "1"}} = rxd
    end
  end
end
