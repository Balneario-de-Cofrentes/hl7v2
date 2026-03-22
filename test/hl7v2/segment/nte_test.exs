defmodule HL7v2.Segment.NTETest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.NTE

  describe "fields/0" do
    test "returns 4 field definitions" do
      assert length(NTE.fields()) == 4
    end
  end

  describe "segment_id/0" do
    test "returns NTE" do
      assert NTE.segment_id() == "NTE"
    end
  end

  describe "parse/1" do
    test "parses set_id and single comment" do
      raw = ["1", "", "Patient is allergic to penicillin"]

      result = NTE.parse(raw)

      assert %NTE{} = result
      assert result.set_id == 1
      assert result.source_of_comment == nil
      assert result.comment == ["Patient is allergic to penicillin"]
    end

    test "parses with set_id, source, and comment" do
      raw = ["2", "L", "Lab note about specimen quality"]

      result = NTE.parse(raw)

      assert result.set_id == 2
      assert result.source_of_comment == "L"
      assert result.comment == ["Lab note about specimen quality"]
    end

    test "parses repeating comment (list of strings)" do
      raw = ["1", "", ["Line 1", "Line 2", "Line 3"]]

      result = NTE.parse(raw)

      assert result.comment == ["Line 1", "Line 2", "Line 3"]
    end

    test "parses with comment_type as CE" do
      raw = ["1", "P", "Important note", ["RE", "Remark", "HL70364"]]

      result = NTE.parse(raw)

      assert result.set_id == 1
      assert result.source_of_comment == "P"
      assert result.comment == ["Important note"]
      assert %HL7v2.Type.CE{identifier: "RE", text: "Remark"} = result.comment_type
    end

    test "parses empty list — all fields nil" do
      result = NTE.parse([])

      assert %NTE{} = result
      assert result.set_id == nil
      assert result.source_of_comment == nil
      assert result.comment == nil
      assert result.comment_type == nil
    end
  end

  describe "encode/1" do
    test "round-trip with set_id and comment" do
      raw = ["1", "", "Patient note"]

      encoded = raw |> NTE.parse() |> NTE.encode()

      assert Enum.at(encoded, 0) == "1"
      # source_of_comment was empty -> nil -> encodes as ""
      assert Enum.at(encoded, 1) == ""
      assert Enum.at(encoded, 2) == "Patient note"
    end

    test "round-trip with repeating comment" do
      raw = ["1", "", ["Line 1", "Line 2"]]

      parsed = NTE.parse(raw)
      encoded = NTE.encode(parsed)

      # Two repetitions should produce a list of wrapped values
      assert Enum.at(encoded, 0) == "1"
      assert Enum.at(encoded, 2) == [["Line 1"], ["Line 2"]]
    end

    test "trailing nil fields trimmed" do
      nte = %NTE{set_id: 1}

      encoded = NTE.encode(nte)

      assert encoded == ["1"]
    end

    test "encodes all-nil struct to empty list" do
      assert NTE.encode(%NTE{}) == []
    end
  end
end
