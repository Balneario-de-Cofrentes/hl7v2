defmodule HL7v2.Type.QIPTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.QIP

  doctest QIP

  describe "parse/1" do
    test "parses field name and value" do
      result = QIP.parse(["@PID.3.1", "12345"])
      assert result.segment_field_name == "@PID.3.1"
      assert result.values == "12345"
    end

    test "parses empty list" do
      assert QIP.parse([]).segment_field_name == nil
    end
  end

  describe "encode/1" do
    test "encodes QIP" do
      qip = %QIP{segment_field_name: "@PID.3.1", values: "12345"}
      assert QIP.encode(qip) == ["@PID.3.1", "12345"]
    end

    test "encodes nil" do
      assert QIP.encode(nil) == []
    end
  end

  describe "round-trip" do
    test "round-trips" do
      components = ["@PID.3.1", "12345"]
      assert components |> QIP.parse() |> QIP.encode() == components
    end
  end
end
