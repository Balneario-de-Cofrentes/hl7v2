defmodule HL7v2.Type.TQTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.TQ
  alias HL7v2.Type.{CQ, CE, TS, DTM}

  doctest TQ

  describe "parse/1" do
    test "parses quantity with duration and start time" do
      result = TQ.parse(["1&mL", "", "S10", "20260322143000"])

      assert %CQ{quantity: "1", units: %CE{identifier: "mL"}} = result.quantity
      assert result.interval == nil
      assert result.duration == "S10"

      assert %TS{time: %DTM{year: 2026, month: 3, day: 22, hour: 14, minute: 30, second: 0}} =
               result.start_date_time
    end

    test "parses with all primitive fields" do
      result =
        TQ.parse([
          "1",
          "Q6H",
          "D3",
          "20260322",
          "20260325",
          "R",
          "NPO",
          "Take with food",
          "S",
          "",
          "30&min&UCUM",
          "12"
        ])

      assert %CQ{quantity: "1"} = result.quantity
      assert result.interval == "Q6H"
      assert result.duration == "D3"
      assert %TS{time: %DTM{year: 2026, month: 3, day: 22}} = result.start_date_time
      assert %TS{time: %DTM{year: 2026, month: 3, day: 25}} = result.end_date_time
      assert result.priority == "R"
      assert result.condition == "NPO"
      assert result.text == "Take with food"
      assert result.conjunction == "S"
      assert result.order_sequencing == nil

      assert %CE{identifier: "30", text: "min", name_of_coding_system: "UCUM"} =
               result.occurrence_duration

      assert result.total_occurrences == "12"
    end

    test "parses quantity only" do
      result = TQ.parse(["5"])
      assert %CQ{quantity: "5"} = result.quantity
      assert result.interval == nil
    end

    test "parses with interval (raw RI string)" do
      result = TQ.parse(["", "Q6H"])
      assert result.quantity == nil
      assert result.interval == "Q6H"
    end

    test "parses with conjunction" do
      result = TQ.parse(["", "", "", "", "", "", "", "", "A"])
      assert result.conjunction == "A"
    end

    test "parses with order sequencing as raw" do
      result = TQ.parse(["", "", "", "", "", "", "", "", "", "1^OBR"])
      assert result.order_sequencing == "1^OBR"
    end

    test "parses empty list" do
      result = TQ.parse([])
      assert result.quantity == nil
      assert result.interval == nil
      assert result.duration == nil
      assert result.start_date_time == nil
      assert result.end_date_time == nil
      assert result.priority == nil
      assert result.condition == nil
      assert result.text == nil
      assert result.conjunction == nil
      assert result.order_sequencing == nil
      assert result.occurrence_duration == nil
      assert result.total_occurrences == nil
    end

    test "parses CQ with units sub-component" do
      # CQ has 2 sub-components: quantity and units (CE)
      # When nested inside TQ, "&" is the sub-component separator
      # so "10&mg" splits into CQ sub-components ["10", "mg"]
      result = TQ.parse(["10&mg"])

      assert %CQ{
               quantity: "10",
               units: %CE{identifier: "mg"}
             } = result.quantity
    end
  end

  describe "encode/1" do
    test "encodes full TQ" do
      tq = %TQ{
        quantity: %CQ{quantity: "1"},
        interval: "Q6H",
        duration: "D3",
        start_date_time: %TS{time: %DTM{year: 2026, month: 3, day: 22}},
        priority: "R"
      }

      assert TQ.encode(tq) == ["1", "Q6H", "D3", "20260322", "", "R"]
    end

    test "encodes quantity only" do
      assert TQ.encode(%TQ{quantity: %CQ{quantity: "5"}}) == ["5"]
    end

    test "encodes with CQ units" do
      tq = %TQ{
        quantity: %CQ{quantity: "1", units: %CE{identifier: "mL"}},
        duration: "S10"
      }

      assert TQ.encode(tq) == ["1&mL", "", "S10"]
    end

    test "encodes with occurrence duration" do
      tq = %TQ{
        quantity: %CQ{quantity: "1"},
        occurrence_duration: %CE{identifier: "30", text: "min", name_of_coding_system: "UCUM"},
        total_occurrences: "12"
      }

      encoded = TQ.encode(tq)
      # Components 2-9 should be empty, then occurrence_duration, total_occurrences
      assert Enum.at(encoded, 0) == "1"
      assert Enum.at(encoded, 10) == "30&min&UCUM"
      assert Enum.at(encoded, 11) == "12"
    end

    test "encodes nil" do
      assert TQ.encode(nil) == []
    end

    test "encodes empty struct" do
      assert TQ.encode(%TQ{}) == []
    end
  end

  describe "round-trip" do
    test "quantity with duration round-trips" do
      components = ["1", "", "S10"]
      assert components |> TQ.parse() |> TQ.encode() == components
    end

    test "quantity with interval round-trips" do
      components = ["5", "Q6H"]
      assert components |> TQ.parse() |> TQ.encode() == components
    end

    test "full TQ round-trips" do
      components = [
        "1",
        "Q6H",
        "D3",
        "20260322",
        "20260325",
        "R",
        "NPO",
        "Take with food",
        "S",
        "",
        "30&min&UCUM",
        "12"
      ]

      assert components |> TQ.parse() |> TQ.encode() == components
    end

    test "quantity with units round-trips" do
      components = ["10&mg"]
      assert components |> TQ.parse() |> TQ.encode() == components
    end
  end
end
