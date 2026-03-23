defmodule HL7v2.Segment.RXRTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.RXR
  alias HL7v2.Type.{CE, CWE}

  describe "fields/0" do
    test "returns 6 field definitions" do
      assert length(RXR.fields()) == 6
    end
  end

  describe "segment_id/0" do
    test "returns RXR" do
      assert RXR.segment_id() == "RXR"
    end
  end

  describe "parse/1" do
    test "parses route as CE" do
      raw = [["PO", "Oral", "HL70162"]]

      result = RXR.parse(raw)

      assert %RXR{} = result
      assert %CE{identifier: "PO", text: "Oral", name_of_coding_system: "HL70162"} = result.route
    end

    test "parses administration_site as CWE" do
      raw = [["IV", "Intravenous"], ["LA", "Left Arm", "HL70550"]]

      result = RXR.parse(raw)

      assert %CWE{identifier: "LA", text: "Left Arm"} = result.administration_site
    end

    test "parses administration_device as CE" do
      raw = [["PO", "Oral"], "", ["NEB", "Nebulizer"]]

      result = RXR.parse(raw)

      assert %CE{identifier: "NEB", text: "Nebulizer"} = result.administration_device
    end

    test "parses administration_method as CWE" do
      raw = [["IV", "Intravenous"], "", "", ["IV", "IV Push", "HL70165"]]

      result = RXR.parse(raw)

      assert %CWE{identifier: "IV", text: "IV Push"} = result.administration_method
    end

    test "parses routing_instruction and administration_site_modifier" do
      raw = [
        ["PO", "Oral"],
        "",
        "",
        "",
        ["SWALLOW", "Swallow whole"],
        ["ANT", "Anterior", "HL70495"]
      ]

      result = RXR.parse(raw)

      assert %CE{identifier: "SWALLOW"} = result.routing_instruction
      assert %CWE{identifier: "ANT", text: "Anterior"} = result.administration_site_modifier
    end

    test "parses all fields together" do
      raw = [
        ["PO", "Oral"],
        ["LA", "Left Arm"],
        ["NEB", "Nebulizer"],
        ["IV", "IV Push"],
        ["SWALLOW", "Swallow whole"],
        ["ANT", "Anterior"]
      ]

      result = RXR.parse(raw)

      assert result.route.identifier == "PO"
      assert result.administration_site.identifier == "LA"
      assert result.administration_device.identifier == "NEB"
      assert result.administration_method.identifier == "IV"
      assert result.routing_instruction.identifier == "SWALLOW"
      assert result.administration_site_modifier.identifier == "ANT"
    end

    test "parses empty list -- all fields nil" do
      result = RXR.parse([])

      assert %RXR{} = result
      assert result.route == nil
      assert result.administration_site == nil
    end

    test "parses empty string fields as nil" do
      raw = List.duplicate("", 6)

      result = RXR.parse(raw)

      assert result.route == nil
      assert result.administration_site == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [["PO", "Oral"], ["LA", "Left Arm"], ["NEB", "Nebulizer"]]

      encoded = raw |> RXR.parse() |> RXR.encode()
      reparsed = RXR.parse(encoded)

      assert reparsed.route.identifier == "PO"
      assert reparsed.administration_site.identifier == "LA"
      assert reparsed.administration_device.identifier == "NEB"
    end

    test "trailing nil fields trimmed" do
      rxr = %RXR{route: CE.parse(["PO", "Oral"])}

      encoded = RXR.encode(rxr)

      assert length(encoded) == 1
    end

    test "encodes all-nil struct to empty list" do
      assert RXR.encode(%RXR{}) == []
    end
  end

  describe "typed parsing integration" do
    test "message with RXR parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||RDE^O11|1|P|2.5.1\r" <>
          "RXR|PO^Oral^HL70162|LA^Left Arm\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      rxr = Enum.find(msg.segments, &is_struct(&1, RXR))
      assert %RXR{route: %CE{identifier: "PO"}} = rxr
    end
  end
end
