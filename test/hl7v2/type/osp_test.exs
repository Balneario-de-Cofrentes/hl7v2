defmodule HL7v2.Type.OSPTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.{OSP, CNE}

  doctest OSP

  describe "parse/1" do
    test "parses code and date range" do
      result = OSP.parse(["70&Qualifying stay&NUBC", "20260101", "20260115"])
      assert %CNE{identifier: "70"} = result.occurrence_span_code
      assert result.occurrence_span_start_date == ~D[2026-01-01]
      assert result.occurrence_span_stop_date == ~D[2026-01-15]
    end

    test "parses empty list" do
      assert OSP.parse([]).occurrence_span_code == nil
    end
  end

  describe "encode/1" do
    test "encodes nil" do
      assert OSP.encode(nil) == []
    end
  end
end
