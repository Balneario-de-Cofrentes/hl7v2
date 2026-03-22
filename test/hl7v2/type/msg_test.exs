defmodule HL7v2.Type.MSGTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.MSG

  doctest MSG

  describe "parse/1" do
    test "parses all three components" do
      result = MSG.parse(["ADT", "A01", "ADT_A01"])

      assert result.message_code == "ADT"
      assert result.trigger_event == "A01"
      assert result.message_structure == "ADT_A01"
    end

    test "parses without message structure" do
      result = MSG.parse(["ADT", "A01"])

      assert result.message_code == "ADT"
      assert result.trigger_event == "A01"
      assert result.message_structure == nil
    end

    test "parses code only" do
      result = MSG.parse(["ACK"])

      assert result.message_code == "ACK"
      assert result.trigger_event == nil
    end

    test "parses empty list" do
      result = MSG.parse([])
      assert %MSG{} = result
    end
  end

  describe "encode/1" do
    test "encodes nil returns empty list" do
      assert MSG.encode(nil) == []
    end

    test "encodes empty struct" do
      assert MSG.encode(%MSG{}) == []
    end

    test "encodes all three components" do
      msg = %MSG{message_code: "ADT", trigger_event: "A01", message_structure: "ADT_A01"}
      assert MSG.encode(msg) == ["ADT", "A01", "ADT_A01"]
    end

    test "encodes without structure (trims trailing)" do
      msg = %MSG{message_code: "ADT", trigger_event: "A01"}
      assert MSG.encode(msg) == ["ADT", "A01"]
    end

    test "encodes code only" do
      msg = %MSG{message_code: "ACK"}
      assert MSG.encode(msg) == ["ACK"]
    end

    test "encode round-trip" do
      original = %MSG{message_code: "ORU", trigger_event: "R01", message_structure: "ORU_R01"}
      parsed = original |> MSG.encode() |> MSG.parse()
      assert parsed == original
    end
  end
end
