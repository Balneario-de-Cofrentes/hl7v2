defmodule HL7v2.Type.QSCTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.QSC

  doctest QSC

  describe "parse/1" do
    test "parses all components" do
      result = QSC.parse(["@PID.3", "EQ", "12345", "AND"])
      assert result.segment_field_name == "@PID.3"
      assert result.relational_operator == "EQ"
      assert result.value == "12345"
      assert result.relational_conjunction == "AND"
    end

    test "parses without conjunction" do
      result = QSC.parse(["@PID.5.1", "CT", "Smith"])
      assert result.segment_field_name == "@PID.5.1"
      assert result.relational_conjunction == nil
    end

    test "parses empty list" do
      assert QSC.parse([]).segment_field_name == nil
    end
  end

  describe "encode/1" do
    test "encodes QSC" do
      qsc = %QSC{segment_field_name: "@PID.3", relational_operator: "EQ", value: "12345"}
      assert QSC.encode(qsc) == ["@PID.3", "EQ", "12345"]
    end

    test "encodes nil" do
      assert QSC.encode(nil) == []
    end
  end

  describe "round-trip" do
    test "round-trips" do
      components = ["@PID.3", "EQ", "12345", "AND"]
      assert components |> QSC.parse() |> QSC.encode() == components
    end
  end
end
