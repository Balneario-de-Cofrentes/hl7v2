defmodule HL7v2.Type.ERLTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.ERL
  alias HL7v2.Type.NM

  doctest ERL

  describe "parse/1" do
    test "parses all six components" do
      result = ERL.parse(["PID", "1", "5", "2", "1", "HL70001"])
      assert result.segment_id == "PID"
      assert %NM{value: "1"} = result.segment_sequence
      assert %NM{value: "5"} = result.field_position
      assert %NM{value: "2"} = result.component_number
      assert %NM{value: "1"} = result.sub_component_number
      assert result.source_table == "HL70001"
    end

    test "parses segment, sequence, and field only" do
      result = ERL.parse(["PID", "1", "5"])
      assert result.segment_id == "PID"
      assert %NM{value: "1"} = result.segment_sequence
      assert %NM{value: "5"} = result.field_position
      assert result.component_number == nil
      assert result.sub_component_number == nil
      assert result.source_table == nil
    end

    test "parses segment only" do
      result = ERL.parse(["PID"])
      assert result.segment_id == "PID"
      assert result.segment_sequence == nil
    end

    test "parses empty list" do
      result = ERL.parse([])
      assert result.segment_id == nil
      assert result.segment_sequence == nil
      assert result.field_position == nil
      assert result.component_number == nil
      assert result.sub_component_number == nil
      assert result.source_table == nil
    end
  end

  describe "encode/1" do
    test "encodes all six components" do
      erl = %ERL{
        segment_id: "PID",
        segment_sequence: %NM{value: "1", original: "1"},
        field_position: %NM{value: "5", original: "5"},
        component_number: %NM{value: "2", original: "2"},
        sub_component_number: %NM{value: "1", original: "1"},
        source_table: "HL70001"
      }

      assert ERL.encode(erl) == ["PID", "1", "5", "2", "1", "HL70001"]
    end

    test "encodes segment, sequence, and field" do
      erl = %ERL{
        segment_id: "PID",
        segment_sequence: %NM{value: "1", original: "1"},
        field_position: %NM{value: "5", original: "5"}
      }

      assert ERL.encode(erl) == ["PID", "1", "5"]
    end

    test "encodes with plain string values (backward compat)" do
      erl = %ERL{segment_id: "PID", segment_sequence: "1", field_position: "5"}
      assert ERL.encode(erl) == ["PID", "1", "5"]
    end

    test "encodes nil" do
      assert ERL.encode(nil) == []
    end

    test "encodes empty struct" do
      assert ERL.encode(%ERL{}) == []
    end
  end

  describe "round-trip" do
    test "full ERL round-trips" do
      components = ["PID", "1", "5", "2", "1", "HL70001"]
      assert components |> ERL.parse() |> ERL.encode() == components
    end

    test "partial ERL round-trips" do
      components = ["PID", "1", "5"]
      assert components |> ERL.parse() |> ERL.encode() == components
    end
  end
end
