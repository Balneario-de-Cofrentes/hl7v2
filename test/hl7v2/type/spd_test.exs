defmodule HL7v2.Type.SPDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.SPD

  doctest SPD

  describe "parse/1" do
    test "parses full specialty" do
      result = SPD.parse(["Cardiology", "ABIM", "C", "20200601"])
      assert result.specialty_name == "Cardiology"
      assert result.governing_board == "ABIM"
      assert result.eligible_or_certified == "C"
      assert result.date_of_certification == ~D[2020-06-01]
    end

    test "parses name only" do
      result = SPD.parse(["Internal Medicine"])
      assert result.specialty_name == "Internal Medicine"
      assert result.governing_board == nil
    end

    test "parses empty list" do
      assert SPD.parse([]).specialty_name == nil
    end
  end

  describe "encode/1" do
    test "encodes SPD" do
      spd = %SPD{
        specialty_name: "Cardiology",
        governing_board: "ABIM",
        eligible_or_certified: "C",
        date_of_certification: ~D[2020-06-01]
      }

      assert SPD.encode(spd) == ["Cardiology", "ABIM", "C", "20200601"]
    end

    test "encodes nil" do
      assert SPD.encode(nil) == []
    end
  end

  describe "round-trip" do
    test "round-trips" do
      components = ["Cardiology", "ABIM", "C", "20200601"]
      assert components |> SPD.parse() |> SPD.encode() == components
    end
  end
end
