defmodule HL7v2.Type.OCDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.{OCD, CNE}

  doctest OCD

  describe "parse/1" do
    test "parses code and date" do
      result = OCD.parse(["01&Accident&NUBC", "20260115"])
      assert %CNE{identifier: "01", text: "Accident"} = result.occurrence_code
      assert result.occurrence_date == ~D[2026-01-15]
    end

    test "parses empty list" do
      assert OCD.parse([]).occurrence_code == nil
    end
  end

  describe "encode/1" do
    test "encodes OCD" do
      ocd = %OCD{occurrence_code: %CNE{identifier: "01"}, occurrence_date: ~D[2026-01-15]}
      assert OCD.encode(ocd) == ["01", "20260115"]
    end

    test "encodes nil" do
      assert OCD.encode(nil) == []
    end
  end
end
