defmodule HL7v2.Type.DINTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.{DIN, CE, TS, DTM}

  doctest DIN

  describe "parse/1" do
    test "parses date and institution" do
      result = DIN.parse(["20260101", "HOSP1&City Hospital&LOCAL"])
      assert %TS{time: %DTM{year: 2026, month: 1, day: 1}} = result.date
      assert %CE{identifier: "HOSP1", text: "City Hospital"} = result.institution_name
    end

    test "parses empty list" do
      result = DIN.parse([])
      assert result.date == nil
      assert result.institution_name == nil
    end
  end

  describe "encode/1" do
    test "encodes institution only" do
      din = %DIN{institution_name: %CE{identifier: "HOSP1"}}
      assert DIN.encode(din) == ["", "HOSP1"]
    end

    test "encodes nil" do
      assert DIN.encode(nil) == []
    end
  end
end
