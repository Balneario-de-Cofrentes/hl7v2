defmodule HL7v2.Type.VRTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.VR

  doctest VR

  describe "parse/1" do
    test "parses range" do
      result = VR.parse(["A", "Z"])
      assert result.first_data_code_value == "A"
      assert result.last_data_code_value == "Z"
    end

    test "parses single value" do
      result = VR.parse(["100"])
      assert result.first_data_code_value == "100"
      assert result.last_data_code_value == nil
    end

    test "parses empty list" do
      assert VR.parse([]).first_data_code_value == nil
    end
  end

  describe "encode/1" do
    test "encodes range" do
      vr = %VR{first_data_code_value: "A", last_data_code_value: "Z"}
      assert VR.encode(vr) == ["A", "Z"]
    end

    test "encodes nil" do
      assert VR.encode(nil) == []
    end
  end

  describe "round-trip" do
    test "round-trips" do
      components = ["A", "Z"]
      assert components |> VR.parse() |> VR.encode() == components
    end
  end
end
