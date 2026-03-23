defmodule HL7v2.Segment.DSCTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.DSC

  describe "fields/0" do
    test "returns 2 field definitions" do
      assert length(DSC.fields()) == 2
    end
  end

  describe "segment_id/0" do
    test "returns DSC" do
      assert DSC.segment_id() == "DSC"
    end
  end

  describe "parse/1" do
    test "parses continuation_pointer" do
      raw = ["NEXT_PAGE_12345"]

      result = DSC.parse(raw)

      assert %DSC{} = result
      assert result.continuation_pointer == "NEXT_PAGE_12345"
    end

    test "parses continuation_style" do
      raw = ["", "I"]

      result = DSC.parse(raw)

      assert result.continuation_style == "I"
    end

    test "parses both fields together" do
      raw = ["CURSOR_ABC", "I"]

      result = DSC.parse(raw)

      assert result.continuation_pointer == "CURSOR_ABC"
      assert result.continuation_style == "I"
    end

    test "parses empty list -- all fields nil" do
      result = DSC.parse([])

      assert %DSC{} = result
      assert result.continuation_pointer == nil
      assert result.continuation_style == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = ["CURSOR_ABC", "I"]

      encoded = raw |> DSC.parse() |> DSC.encode()
      reparsed = DSC.parse(encoded)

      assert reparsed.continuation_pointer == "CURSOR_ABC"
      assert reparsed.continuation_style == "I"
    end

    test "trailing nil fields trimmed" do
      dsc = %DSC{continuation_pointer: "PAGE_2"}

      encoded = DSC.encode(dsc)

      assert length(encoded) == 1
    end

    test "encodes all-nil struct to empty list" do
      assert DSC.encode(%DSC{}) == []
    end
  end

  describe "typed parsing integration" do
    test "message with DSC parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||QRY^A19|1|P|2.5.1\r" <>
          "DSC|NEXT_PAGE_12345|I\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      dsc = Enum.find(msg.segments, &is_struct(&1, DSC))
      assert %DSC{continuation_pointer: "NEXT_PAGE_12345", continuation_style: "I"} = dsc
    end
  end
end
