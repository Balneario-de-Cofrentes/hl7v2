defmodule HL7v2.Type.ELDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.ELD
  alias HL7v2.Type.CE

  doctest ELD

  describe "parse/1" do
    test "parses full ELD with error code" do
      result = ELD.parse(["PID", "1", "4", "101&Required field missing&HL70357"])

      assert result.segment_id == "PID"
      assert result.segment_sequence == "1"
      assert result.field_position == "4"

      assert %CE{
               identifier: "101",
               text: "Required field missing",
               name_of_coding_system: "HL70357"
             } = result.code_identifying_error
    end

    test "parses segment and sequence only" do
      result = ELD.parse(["PID", "1"])
      assert result.segment_id == "PID"
      assert result.segment_sequence == "1"
      assert result.field_position == nil
      assert result.code_identifying_error == nil
    end

    test "parses segment only" do
      result = ELD.parse(["MSH"])
      assert result.segment_id == "MSH"
      assert result.segment_sequence == nil
    end

    test "parses with simple error code" do
      result = ELD.parse(["PID", "1", "3", "102"])
      assert %CE{identifier: "102"} = result.code_identifying_error
    end

    test "parses empty list" do
      result = ELD.parse([])
      assert result.segment_id == nil
      assert result.segment_sequence == nil
      assert result.field_position == nil
      assert result.code_identifying_error == nil
    end
  end

  describe "encode/1" do
    test "encodes full ELD" do
      eld = %ELD{
        segment_id: "PID",
        segment_sequence: "1",
        field_position: "4",
        code_identifying_error: %CE{
          identifier: "101",
          text: "Required field missing",
          name_of_coding_system: "HL70357"
        }
      }

      assert ELD.encode(eld) == ["PID", "1", "4", "101&Required field missing&HL70357"]
    end

    test "encodes partial ELD" do
      assert ELD.encode(%ELD{segment_id: "PID", segment_sequence: "1"}) == ["PID", "1"]
    end

    test "encodes nil" do
      assert ELD.encode(nil) == []
    end

    test "encodes empty struct" do
      assert ELD.encode(%ELD{}) == []
    end
  end

  describe "round-trip" do
    test "full ELD round-trips" do
      components = ["PID", "1", "4", "101&Required field missing&HL70357"]
      assert components |> ELD.parse() |> ELD.encode() == components
    end

    test "partial ELD round-trips" do
      components = ["PID", "1"]
      assert components |> ELD.parse() |> ELD.encode() == components
    end

    test "segment-only round-trips" do
      components = ["MSH"]
      assert components |> ELD.parse() |> ELD.encode() == components
    end
  end
end
