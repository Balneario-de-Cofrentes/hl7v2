defmodule HL7v2.Type.SRTTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.SRT

  doctest SRT

  describe "parse/1" do
    test "parses sort field and sequencing" do
      result = SRT.parse(["PID.3", "A"])
      assert result.sort_by_field == "PID.3"
      assert result.sequencing == "A"
    end

    test "parses empty list" do
      assert SRT.parse([]).sort_by_field == nil
    end
  end

  describe "encode/1" do
    test "encodes SRT" do
      srt = %SRT{sort_by_field: "PID.3", sequencing: "A"}
      assert SRT.encode(srt) == ["PID.3", "A"]
    end

    test "encodes nil" do
      assert SRT.encode(nil) == []
    end
  end

  describe "round-trip" do
    test "round-trips" do
      components = ["PID.3", "A"]
      assert components |> SRT.parse() |> SRT.encode() == components
    end
  end
end
