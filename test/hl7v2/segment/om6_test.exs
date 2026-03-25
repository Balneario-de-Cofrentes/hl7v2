defmodule HL7v2.Segment.OM6Test do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.OM6

  describe "fields/0" do
    test "returns 1 field definition" do
      assert length(OM6.fields()) == 1
    end
  end

  describe "segment_id/0" do
    test "returns OM6" do
      assert OM6.segment_id() == "OM6"
    end
  end

  describe "parse/1" do
    test "parses derivation_rule" do
      raw = ["A+B/C"]

      result = OM6.parse(raw)

      assert %OM6{} = result
      assert result.derivation_rule == "A+B/C"
    end

    test "parses empty list" do
      result = OM6.parse([])

      assert %OM6{} = result
      assert result.derivation_rule == nil
    end
  end

  describe "encode/1" do
    test "encodes all-nil struct to empty list" do
      assert OM6.encode(%OM6{}) == []
    end

    test "round-trip preserves data" do
      raw = ["A+B/C"]

      encoded = raw |> OM6.parse() |> OM6.encode()

      assert Enum.at(encoded, 0) == "A+B/C"
    end
  end
end
