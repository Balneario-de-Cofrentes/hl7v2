defmodule HL7v2.Segment.TCDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.TCD

  describe "fields/0" do
    test "returns 8 field definitions" do
      assert length(TCD.fields()) == 8
    end
  end

  describe "segment_id/0" do
    test "returns TCD" do
      assert TCD.segment_id() == "TCD"
    end
  end

  describe "parse/1" do
    test "parses universal_service_identifier" do
      raw = [["GLUC", "Glucose"]]

      result = TCD.parse(raw)

      assert %TCD{} = result
      assert %HL7v2.Type.CE{identifier: "GLUC"} = result.universal_service_identifier
    end

    test "parses automatic_repeat_allowed and reflex_allowed" do
      raw = List.duplicate("", 5) ++ ["Y", "N"]

      result = TCD.parse(raw)

      assert result.automatic_repeat_allowed == "Y"
      assert result.reflex_allowed == "N"
    end

    test "parses analyte_repeatability" do
      raw = List.duplicate("", 7) ++ [["REP", "Repeatable"]]

      result = TCD.parse(raw)

      assert %HL7v2.Type.CE{identifier: "REP"} = result.analyte_repeatability
    end

    test "parses empty list" do
      result = TCD.parse([])

      assert %TCD{} = result
      assert result.universal_service_identifier == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert TCD.encode(%TCD{}) == []
    end

    test "round-trip preserves data" do
      raw = [["GLUC", "Glucose"]]

      encoded = raw |> TCD.parse() |> TCD.encode()

      assert Enum.at(encoded, 0) == ["GLUC", "Glucose"]
    end
  end
end
