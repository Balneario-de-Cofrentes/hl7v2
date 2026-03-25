defmodule HL7v2.Type.LA1Test do
  use ExUnit.Case, async: true

  alias HL7v2.Type.LA1

  doctest LA1

  describe "parse/1" do
    test "parses location fields" do
      result = LA1.parse(["ICU", "101", "A"])
      assert result.point_of_care == "ICU"
      assert result.room == "101"
      assert result.bed == "A"
    end

    test "parses empty list" do
      assert LA1.parse([]).point_of_care == nil
    end
  end

  describe "encode/1" do
    test "encodes location" do
      la1 = %LA1{point_of_care: "ICU", room: "101"}
      assert LA1.encode(la1) == ["ICU", "101"]
    end

    test "encodes nil" do
      assert LA1.encode(nil) == []
    end
  end

  describe "round-trip" do
    test "round-trips" do
      components = ["ICU", "101", "A"]
      assert components |> LA1.parse() |> LA1.encode() == components
    end
  end
end
