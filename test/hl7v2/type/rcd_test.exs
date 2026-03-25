defmodule HL7v2.Type.RCDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.RCD

  doctest RCD

  describe "parse/1" do
    test "parses all components" do
      result = RCD.parse(["PID.3", "CX", "20"])
      assert result.segment_field_name == "PID.3"
      assert result.hl7_data_type == "CX"
      assert result.maximum_column_width == "20"
    end

    test "parses empty list" do
      assert RCD.parse([]).segment_field_name == nil
    end
  end

  describe "encode/1" do
    test "encodes RCD" do
      rcd = %RCD{segment_field_name: "PID.3", hl7_data_type: "CX", maximum_column_width: "20"}
      assert RCD.encode(rcd) == ["PID.3", "CX", "20"]
    end

    test "encodes nil" do
      assert RCD.encode(nil) == []
    end
  end

  describe "round-trip" do
    test "round-trips" do
      components = ["PID.3", "CX", "20"]
      assert components |> RCD.parse() |> RCD.encode() == components
    end
  end
end
