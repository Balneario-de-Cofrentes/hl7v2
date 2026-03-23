defmodule HL7v2.Segment.RXCTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.RXC
  alias HL7v2.Type.{CE, CWE, NM}

  describe "fields/0" do
    test "returns 9 field definitions" do
      assert length(RXC.fields()) == 9
    end
  end

  describe "segment_id/0" do
    test "returns RXC" do
      assert RXC.segment_id() == "RXC"
    end
  end

  describe "parse/1" do
    test "parses rx_component_type and component_code" do
      raw = ["B", ["NS", "Normal Saline", "NDC"]]

      result = RXC.parse(raw)

      assert %RXC{} = result
      assert result.rx_component_type == "B"
      assert %CE{identifier: "NS", text: "Normal Saline"} = result.component_code
    end

    test "parses component_amount and component_units" do
      raw = ["A", ["KCL", "Potassium Chloride"], "20", ["mEq", "milliequivalent"]]

      result = RXC.parse(raw)

      assert result.rx_component_type == "A"
      assert %NM{value: "20"} = result.component_amount
      assert %CE{identifier: "mEq"} = result.component_units
    end

    test "parses component_strength and component_strength_units" do
      raw = [
        "B",
        ["NS", "Normal Saline"],
        "1000",
        ["mL", "milliliter"],
        "0.9",
        ["PCT", "Percent"]
      ]

      result = RXC.parse(raw)

      assert %NM{value: "0.9"} = result.component_strength
      assert %CE{identifier: "PCT"} = result.component_strength_units
    end

    test "parses supplementary_code as repeating CE" do
      raw = List.duplicate("", 6) ++ [[["S1", "Supp1"], ["S2", "Supp2"]]]

      result = RXC.parse(raw)

      assert [%CE{identifier: "S1"}, %CE{identifier: "S2"}] = result.supplementary_code
    end

    test "parses component_drug_strength_volume and units" do
      raw = List.duplicate("", 7) ++ ["50", ["mL", "milliliter", "ISO+"]]

      result = RXC.parse(raw)

      assert %NM{value: "50"} = result.component_drug_strength_volume
      assert %CWE{identifier: "mL"} = result.component_drug_strength_volume_units
    end

    test "parses empty list -- all fields nil" do
      result = RXC.parse([])

      assert %RXC{} = result
      assert result.rx_component_type == nil
      assert result.component_code == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["B", ["NS", "Normal Saline"], "1000", ["mL", "milliliter"]]

      encoded = raw |> RXC.parse() |> RXC.encode()
      reparsed = RXC.parse(encoded)

      assert reparsed.rx_component_type == "B"
      assert reparsed.component_code.identifier == "NS"
      assert %NM{value: "1000"} = reparsed.component_amount
      assert reparsed.component_units.identifier == "mL"
    end

    test "trailing nil fields trimmed" do
      rxc = %RXC{rx_component_type: "B", component_code: CE.parse(["NS", "Normal Saline"])}

      encoded = RXC.encode(rxc)

      assert length(encoded) == 2
    end

    test "encodes all-nil struct to empty list" do
      assert RXC.encode(%RXC{}) == []
    end
  end

  describe "typed parsing integration" do
    test "message with RXC parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||RDE^O11|1|P|2.5.1\r" <>
          "RXC|B|NS^Normal Saline|1000|mL^milliliter\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      rxc = Enum.find(msg.segments, &is_struct(&1, RXC))
      assert %RXC{rx_component_type: "B"} = rxc
    end
  end
end
