defmodule HL7v2.Segment.RXETest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.RXE
  alias HL7v2.Type.{CE, CQ, NM, XCN, FN}

  describe "fields/0" do
    test "returns 44 field definitions" do
      assert length(RXE.fields()) == 44
    end
  end

  describe "segment_id/0" do
    test "returns RXE" do
      assert RXE.segment_id() == "RXE"
    end
  end

  describe "parse/1" do
    test "parses quantity_timing as TQ" do
      raw = [["1", "QD"]]

      result = RXE.parse(raw)

      assert %RXE{} = result
      assert %CQ{quantity: "1"} = result.quantity_timing.quantity
      assert result.quantity_timing.interval == "QD"
    end

    test "parses give_code, give_amount_minimum/maximum, give_units" do
      raw = ["", ["RX001", "Amoxicillin"], "250", "500", ["mg", "milligram"]]

      result = RXE.parse(raw)

      assert %CE{identifier: "RX001"} = result.give_code
      assert %NM{value: "250"} = result.give_amount_minimum
      assert %NM{value: "500"} = result.give_amount_maximum
      assert %CE{identifier: "mg"} = result.give_units
    end

    test "parses give_dosage_form and deliver_to_location as raw" do
      raw = List.duplicate("", 5) ++ [["TAB", "Tablet"], "", ["LOC1", "WARD"]]

      result = RXE.parse(raw)

      assert %CE{identifier: "TAB"} = result.give_dosage_form
      assert result.deliver_to_location == ["LOC1", "WARD"]
    end

    test "parses substitution_status and dispense fields" do
      raw = List.duplicate("", 8) ++ ["G", "30", ["TAB", "Tablet"], "3"]

      result = RXE.parse(raw)

      assert result.substitution_status == "G"
      assert %NM{value: "30"} = result.dispense_amount
      assert %CE{identifier: "TAB"} = result.dispense_units
      assert %NM{value: "3"} = result.number_of_refills
    end

    test "parses ordering_providers_dea_number as repeating XCN" do
      raw = List.duplicate("", 12) ++ [["DEA123", "Smith"]]

      result = RXE.parse(raw)

      assert [%XCN{id_number: "DEA123", family_name: %FN{surname: "Smith"}}] =
               result.ordering_providers_dea_number
    end

    test "parses prescription_number and refill counts" do
      raw = List.duplicate("", 14) ++ ["RX12345", "2", "1"]

      result = RXE.parse(raw)

      assert result.prescription_number == "RX12345"
      assert %NM{value: "2"} = result.number_of_refills_remaining
      assert %NM{value: "1"} = result.number_of_refills_doses_dispensed
    end

    test "parses total_daily_dose as CQ" do
      raw = List.duplicate("", 18) ++ [["1500", ["mg", "milligram"]]]

      result = RXE.parse(raw)

      assert %CQ{quantity: "1500"} = result.total_daily_dose
    end

    test "parses needs_human_review" do
      raw = List.duplicate("", 19) ++ ["Y"]

      result = RXE.parse(raw)

      assert result.needs_human_review == "Y"
    end

    test "parses give_strength and give_strength_units" do
      raw = List.duplicate("", 24) ++ ["500", ["mg", "milligram"]]

      result = RXE.parse(raw)

      assert %NM{value: "500"} = result.give_strength
      assert %CE{identifier: "mg"} = result.give_strength_units
    end

    test "parses dispense_package_size and method" do
      raw = List.duplicate("", 27) ++ ["100", ["EA", "each"], "TR"]

      result = RXE.parse(raw)

      assert %NM{value: "100"} = result.dispense_package_size
      assert %CE{identifier: "EA"} = result.dispense_package_size_unit
      assert result.dispense_package_method == "TR"
    end

    test "preserves raw fields 32-44" do
      raw = List.duplicate("", 31) ++ ["raw32", "raw33"]

      result = RXE.parse(raw)

      assert result.field_32 == "raw32"
      assert result.field_33 == "raw33"
    end

    test "parses empty list -- all fields nil" do
      result = RXE.parse([])

      assert %RXE{} = result
      assert result.give_code == nil
      assert result.give_units == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [["1", "QD"], ["RX001", "Amoxicillin"], "250", "500", ["mg", "milligram"]]

      encoded = raw |> RXE.parse() |> RXE.encode()
      reparsed = RXE.parse(encoded)

      assert %CQ{quantity: "1"} = reparsed.quantity_timing.quantity
      assert reparsed.give_code.identifier == "RX001"
      assert %NM{value: "250"} = reparsed.give_amount_minimum
      assert reparsed.give_units.identifier == "mg"
    end

    test "raw fields round-trip" do
      raw = List.duplicate("", 31) ++ ["raw32"]

      encoded = raw |> RXE.parse() |> RXE.encode()
      reparsed = RXE.parse(encoded)

      assert reparsed.field_32 == "raw32"
    end

    test "trailing nil fields trimmed" do
      rxe = %RXE{give_code: CE.parse(["RX001"])}

      encoded = RXE.encode(rxe)

      assert length(encoded) == 2
    end

    test "encodes all-nil struct to empty list" do
      assert RXE.encode(%RXE{}) == []
    end
  end

  describe "typed parsing integration" do
    test "message with RXE parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||RDE^O11|1|P|2.5.1\r" <>
          "RXE||RX001^Amoxicillin|250||mg^milligram\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      rxe = Enum.find(msg.segments, &is_struct(&1, RXE))
      assert %RXE{give_code: %CE{identifier: "RX001"}} = rxe
    end
  end
end
