defmodule HL7v2.Segment.FT1Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.FT1
  alias HL7v2.Type.{CE, DR, DTM, EI, PL, TS}

  describe "field count" do
    test "defines 31 fields" do
      assert length(FT1.fields()) == 31
    end
  end

  describe "parse/1" do
    test "parses transaction info" do
      raw = [
        "1",
        "TXN001",
        "BATCH01",
        ["20260301", "20260331"],
        nil,
        "CG",
        ["99213", "Office Visit", "CPT4"]
      ]

      ft1 = FT1.parse(raw)

      assert ft1.set_id == 1
      assert ft1.transaction_id == "TXN001"
      assert ft1.transaction_batch_id == "BATCH01"
      assert ft1.transaction_type == "CG"

      assert %CE{identifier: "99213", text: "Office Visit", name_of_coding_system: "CPT4"} =
               ft1.transaction_code
    end

    test "parses transaction_date as DR composite" do
      raw = [
        "1",
        nil,
        nil,
        ["20260301", "20260331"]
      ]

      ft1 = FT1.parse(raw)

      assert %DR{
               range_start: %TS{time: %DTM{year: 2026, month: 3, day: 1}},
               range_end: %TS{time: %DTM{year: 2026, month: 3, day: 31}}
             } = ft1.transaction_date
    end

    test "parses transaction_date with only start date" do
      raw = [nil, nil, nil, ["20260301"]]

      ft1 = FT1.parse(raw)

      assert %DR{
               range_start: %TS{time: %DTM{year: 2026, month: 3, day: 1}},
               range_end: nil
             } = ft1.transaction_date
    end

    test "parses assigned patient location" do
      # assigned_patient_location is at seq 16
      raw = List.duplicate(nil, 15) ++ [["WARD", "301", "B"]]

      ft1 = FT1.parse(raw)

      assert %PL{point_of_care: "WARD", room: "301", bed: "B"} = ft1.assigned_patient_location
    end

    test "parses filler order number" do
      # filler_order_number is at seq 23
      raw = List.duplicate(nil, 22) ++ [["ORD456", "HOSP"]]

      ft1 = FT1.parse(raw)

      assert %EI{entity_identifier: "ORD456", namespace_id: "HOSP"} = ft1.filler_order_number
    end

    test "parses repeating diagnosis code" do
      # diagnosis_code is at seq 19, repeating
      raw = List.duplicate(nil, 18) ++ [[["J18.9", "Pneumonia"], ["R06.0", "Dyspnea"]]]

      ft1 = FT1.parse(raw)

      assert [
               %CE{identifier: "J18.9", text: "Pneumonia"},
               %CE{identifier: "R06.0", text: "Dyspnea"}
             ] = ft1.diagnosis_code
    end

    test "returns nil for missing optional fields" do
      ft1 = FT1.parse([])

      assert ft1.set_id == nil
      assert ft1.transaction_date == nil
      assert ft1.transaction_type == nil
      assert ft1.transaction_code == nil
    end

    test "parses empty list" do
      ft1 = FT1.parse([])

      assert %FT1{} = ft1
    end
  end

  describe "encode/1" do
    test "encodes FT1 with transaction info" do
      ft1 = %FT1{
        set_id: 1,
        transaction_date: %DR{
          range_start: %TS{time: %DTM{year: 2026, month: 3, day: 1}},
          range_end: %TS{time: %DTM{year: 2026, month: 3, day: 31}}
        },
        transaction_type: "CG",
        transaction_code: %CE{
          identifier: "99213",
          text: "Office Visit",
          name_of_coding_system: "CPT4"
        }
      }

      encoded = FT1.encode(ft1)

      assert Enum.at(encoded, 0) == "1"
      assert Enum.at(encoded, 3) == ["20260301", "20260331"]
      assert Enum.at(encoded, 5) == "CG"
      assert Enum.at(encoded, 6) == ["99213", "Office Visit", "CPT4"]
    end

    test "encodes nil segment fields" do
      ft1 = %FT1{set_id: 1, transaction_type: "CG"}
      encoded = FT1.encode(ft1)

      assert Enum.at(encoded, 0) == "1"
      assert Enum.at(encoded, 5) == "CG"
    end
  end

  describe "round-trip" do
    test "parse then encode preserves transaction data" do
      raw = [
        "1",
        "TXN001",
        nil,
        ["20260301", "20260331"],
        nil,
        "CG",
        ["99213", "Office Visit", "CPT4"]
      ]

      result = raw |> FT1.parse() |> FT1.encode()

      assert Enum.at(result, 0) == "1"
      assert Enum.at(result, 1) == "TXN001"
      assert Enum.at(result, 3) == ["20260301", "20260331"]
      assert Enum.at(result, 5) == "CG"
      assert Enum.at(result, 6) == ["99213", "Office Visit", "CPT4"]
    end

    test "parse then encode preserves DR with single date" do
      raw = [nil, nil, nil, ["20260301"]]

      result = raw |> FT1.parse() |> FT1.encode()

      assert Enum.at(result, 3) == ["20260301"]
    end
  end
end
