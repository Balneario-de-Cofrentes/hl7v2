defmodule HL7v2.Type.LA2Test do
  use ExUnit.Case, async: true

  alias HL7v2.Type.LA2

  doctest LA2

  describe "parse/1" do
    test "parses location with address" do
      result =
        LA2.parse([
          "ICU",
          "101",
          "",
          "",
          "",
          "",
          "",
          "",
          "123 Main St",
          "",
          "Springfield",
          "IL",
          "62704",
          "USA"
        ])

      assert result.point_of_care == "ICU"
      assert result.room == "101"
      assert result.street_address == "123 Main St"
      assert result.city == "Springfield"
      assert result.country == "USA"
    end

    test "parses empty list" do
      assert LA2.parse([]).point_of_care == nil
    end
  end

  describe "encode/1" do
    test "encodes location" do
      la2 = %LA2{point_of_care: "ICU", room: "101", bed: "A"}
      assert LA2.encode(la2) == ["ICU", "101", "A"]
    end

    test "encodes nil" do
      assert LA2.encode(nil) == []
    end
  end
end
