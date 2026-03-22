defmodule HL7v2.Type.EIPTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.EIP
  alias HL7v2.Type.EI

  doctest EIP

  describe "parse/1" do
    test "parses both placer and filler identifiers" do
      result = EIP.parse(["P123&HOSP&2.16.840&ISO", "F456&LAB&2.16.841&ISO"])

      assert %EI{
               entity_identifier: "P123",
               namespace_id: "HOSP",
               universal_id: "2.16.840",
               universal_id_type: "ISO"
             } = result.placer_assigned_identifier

      assert %EI{
               entity_identifier: "F456",
               namespace_id: "LAB",
               universal_id: "2.16.841",
               universal_id_type: "ISO"
             } = result.filler_assigned_identifier
    end

    test "parses placer only" do
      result = EIP.parse(["P123"])
      assert %EI{entity_identifier: "P123"} = result.placer_assigned_identifier
      assert result.filler_assigned_identifier == nil
    end

    test "parses empty list" do
      result = EIP.parse([])
      assert result.placer_assigned_identifier == nil
      assert result.filler_assigned_identifier == nil
    end
  end

  describe "encode/1" do
    test "encodes both identifiers" do
      eip = %EIP{
        placer_assigned_identifier: %EI{entity_identifier: "P123", namespace_id: "HOSP"},
        filler_assigned_identifier: %EI{entity_identifier: "F456", namespace_id: "LAB"}
      }

      assert EIP.encode(eip) == ["P123&HOSP", "F456&LAB"]
    end

    test "encodes placer only" do
      eip = %EIP{placer_assigned_identifier: %EI{entity_identifier: "P123"}}
      assert EIP.encode(eip) == ["P123"]
    end

    test "encodes nil" do
      assert EIP.encode(nil) == []
    end

    test "encodes empty struct" do
      assert EIP.encode(%EIP{}) == []
    end
  end

  describe "round-trip" do
    test "both identifiers round-trip" do
      components = ["P123&HOSP", "F456&LAB"]
      assert components |> EIP.parse() |> EIP.encode() == components
    end

    test "placer-only round-trips" do
      components = ["P123"]
      assert components |> EIP.parse() |> EIP.encode() == components
    end
  end
end
