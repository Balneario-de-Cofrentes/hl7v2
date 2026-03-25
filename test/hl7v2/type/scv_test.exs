defmodule HL7v2.Type.SCVTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.{SCV, CWE}

  doctest SCV

  describe "parse/1" do
    test "parses parameter class and value" do
      result = SCV.parse(["PREFDAY&Preferred Day&HL70294", "MON"])
      assert %CWE{identifier: "PREFDAY", text: "Preferred Day"} = result.parameter_class
      assert result.parameter_value == "MON"
    end

    test "parses empty list" do
      assert SCV.parse([]).parameter_class == nil
    end
  end

  describe "encode/1" do
    test "encodes SCV" do
      scv = %SCV{parameter_class: %CWE{identifier: "PREFDAY"}, parameter_value: "MON"}
      assert SCV.encode(scv) == ["PREFDAY", "MON"]
    end

    test "encodes nil" do
      assert SCV.encode(nil) == []
    end
  end
end
