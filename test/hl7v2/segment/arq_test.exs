defmodule HL7v2.Segment.ARQTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.ARQ

  describe "fields/0" do
    test "returns 25 field definitions" do
      assert length(ARQ.fields()) == 25
    end
  end

  describe "segment_id/0" do
    test "returns ARQ" do
      assert ARQ.segment_id() == "ARQ"
    end
  end

  describe "parse/1" do
    test "parses placer_appointment_id as EI" do
      raw = [["APT001", "HOSP"]]

      result = ARQ.parse(raw)

      assert %ARQ{} = result

      assert %HL7v2.Type.EI{entity_identifier: "APT001", namespace_id: "HOSP"} =
               result.placer_appointment_id
    end

    test "parses appointment_duration as NM" do
      raw = List.duplicate("", 8) ++ ["60"]

      result = ARQ.parse(raw)

      assert %HL7v2.Type.NM{value: "60"} = result.appointment_duration
    end

    test "parses empty list" do
      result = ARQ.parse([])

      assert %ARQ{} = result
      assert result.placer_appointment_id == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert ARQ.encode(%ARQ{}) == []
    end

    test "round-trip preserves placer_appointment_id" do
      raw = [["APT001", "HOSP"]]

      encoded = raw |> ARQ.parse() |> ARQ.encode()

      assert Enum.at(encoded, 0) == ["APT001", "HOSP"]
    end
  end
end
