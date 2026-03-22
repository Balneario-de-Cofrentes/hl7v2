defmodule HL7v2.Type.FCTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.FC
  alias HL7v2.Type.{TS, DTM}

  doctest FC

  describe "parse/1" do
    test "parses financial class code only" do
      result = FC.parse(["01"])
      assert result.financial_class_code == "01"
      assert result.effective_date == nil
    end

    test "parses financial class code with effective date" do
      result = FC.parse(["01", "20260322"])
      assert result.financial_class_code == "01"
      assert %TS{time: %DTM{year: 2026, month: 3, day: 22}} = result.effective_date
    end

    test "parses with sub-component date (degree of precision)" do
      result = FC.parse(["02", "20260322&D"])
      assert result.financial_class_code == "02"
      assert %TS{time: %DTM{year: 2026, month: 3, day: 22}, degree_of_precision: "D"} = result.effective_date
    end

    test "parses empty list" do
      result = FC.parse([])
      assert result.financial_class_code == nil
      assert result.effective_date == nil
    end
  end

  describe "encode/1" do
    test "encodes code only" do
      assert FC.encode(%FC{financial_class_code: "01"}) == ["01"]
    end

    test "encodes code with effective date" do
      fc = %FC{
        financial_class_code: "01",
        effective_date: %TS{time: %DTM{year: 2026, month: 3, day: 22}}
      }

      assert FC.encode(fc) == ["01", "20260322"]
    end

    test "encodes nil" do
      assert FC.encode(nil) == []
    end

    test "encodes empty struct" do
      assert FC.encode(%FC{}) == []
    end
  end

  describe "round-trip" do
    test "code-only round-trips" do
      components = ["01"]
      assert components |> FC.parse() |> FC.encode() == components
    end

    test "full FC round-trips" do
      components = ["01", "20260322"]
      assert components |> FC.parse() |> FC.encode() == components
    end
  end
end
