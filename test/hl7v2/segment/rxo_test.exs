defmodule HL7v2.Segment.RXOTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.RXO
  alias HL7v2.Type.{CE, CQ, LA1, NM, XCN, FN}

  describe "fields/0" do
    test "returns 25 field definitions" do
      assert length(RXO.fields()) == 25
    end
  end

  describe "segment_id/0" do
    test "returns RXO" do
      assert RXO.segment_id() == "RXO"
    end
  end

  describe "parse/1" do
    test "parses requested_give_code and units" do
      raw = [["RX001", "Amoxicillin", "NDC"], "", "", ["mg", "milligram"]]

      result = RXO.parse(raw)

      assert %RXO{} = result
      assert %CE{identifier: "RX001", text: "Amoxicillin"} = result.requested_give_code
      assert %CE{identifier: "mg"} = result.requested_give_units
    end

    test "parses requested_give_amount_minimum and maximum" do
      raw = [["RX001"], "250", "500"]

      result = RXO.parse(raw)

      assert %NM{value: "250"} = result.requested_give_amount_minimum
      assert %NM{value: "500"} = result.requested_give_amount_maximum
    end

    test "parses deliver_to_location as LA1" do
      raw = List.duplicate("", 7) ++ [["LOC1", "WARD-A", "ROOM-1"]]

      result = RXO.parse(raw)

      assert %LA1{point_of_care: "LOC1", room: "WARD-A", bed: "ROOM-1"} =
               result.deliver_to_location
    end

    test "parses allow_substitutions and needs_human_review" do
      raw = List.duplicate("", 8) ++ ["G", "", "", "", "", "", "", "Y"]

      result = RXO.parse(raw)

      assert result.allow_substitutions == "G"
      assert result.needs_human_review == "Y"
    end

    test "parses ordering_providers_dea_number as repeating XCN" do
      raw = List.duplicate("", 13) ++ [["DEA123", "Smith"]]

      result = RXO.parse(raw)

      assert [%XCN{id_number: "DEA123", family_name: %FN{surname: "Smith"}}] =
               result.ordering_providers_dea_number
    end

    test "parses indication as repeating CE" do
      raw = List.duplicate("", 19) ++ [[["IND1", "Infection"], ["IND2", "Prophylaxis"]]]

      result = RXO.parse(raw)

      assert [%CE{identifier: "IND1"}, %CE{identifier: "IND2"}] = result.indication
    end

    test "parses total_daily_dose as CQ" do
      raw = List.duplicate("", 22) ++ [["1500", ["mg", "milligram"]]]

      result = RXO.parse(raw)

      assert %CQ{quantity: "1500"} = result.total_daily_dose
    end

    test "parses requested_drug_strength_volume" do
      raw = List.duplicate("", 24) ++ ["50"]

      result = RXO.parse(raw)

      assert %NM{value: "50"} = result.requested_drug_strength_volume
    end

    test "parses empty list -- all fields nil" do
      result = RXO.parse([])

      assert %RXO{} = result
      assert result.requested_give_code == nil
      assert result.requested_give_units == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [["RX001", "Amoxicillin"], "250", "500", ["mg", "milligram"]]

      encoded = raw |> RXO.parse() |> RXO.encode()
      reparsed = RXO.parse(encoded)

      assert reparsed.requested_give_code.identifier == "RX001"
      assert %NM{value: "250"} = reparsed.requested_give_amount_minimum
      assert %NM{value: "500"} = reparsed.requested_give_amount_maximum
      assert reparsed.requested_give_units.identifier == "mg"
    end

    test "deliver_to_location round-trips" do
      raw = List.duplicate("", 7) ++ [["LOC1", "WARD-A"]]

      encoded = raw |> RXO.parse() |> RXO.encode()
      reparsed = RXO.parse(encoded)

      assert %LA1{point_of_care: "LOC1", room: "WARD-A"} = reparsed.deliver_to_location
    end

    test "trailing nil fields trimmed" do
      rxo = %RXO{requested_give_code: CE.parse(["RX001", "Amoxicillin"])}

      encoded = RXO.encode(rxo)

      assert length(encoded) == 1
    end

    test "encodes all-nil struct to empty list" do
      assert RXO.encode(%RXO{}) == []
    end
  end

  describe "typed parsing integration" do
    test "message with RXO parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||OMP^O09|1|P|2.5.1\r" <>
          "RXO|RX001^Amoxicillin|250|500|mg^milligram\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      rxo = Enum.find(msg.segments, &is_struct(&1, RXO))
      assert %RXO{requested_give_code: %CE{identifier: "RX001"}} = rxo
    end
  end
end
