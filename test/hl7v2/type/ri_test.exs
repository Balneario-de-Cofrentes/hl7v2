defmodule HL7v2.Type.RITest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.RI

  doctest RI

  describe "parse/1" do
    test "parses both components" do
      result = RI.parse(["Q6H", "6 hours"])
      assert result.repeat_pattern == "Q6H"
      assert result.explicit_time_interval == "6 hours"
    end

    test "parses repeat pattern only" do
      result = RI.parse(["BID"])
      assert result.repeat_pattern == "BID"
      assert result.explicit_time_interval == nil
    end

    test "parses explicit interval only" do
      result = RI.parse(["", "300S"])
      assert result.repeat_pattern == nil
      assert result.explicit_time_interval == "300S"
    end

    test "parses empty list" do
      result = RI.parse([])
      assert result.repeat_pattern == nil
      assert result.explicit_time_interval == nil
    end

    test "parses common repeat patterns" do
      for pattern <- ~w(QD BID TID QID QH Q2H Q4H Q6H Q8H QAM QPM) do
        result = RI.parse([pattern])
        assert result.repeat_pattern == pattern
      end
    end
  end

  describe "encode/1" do
    test "encodes full RI" do
      ri = %RI{repeat_pattern: "Q6H", explicit_time_interval: "6 hours"}
      assert RI.encode(ri) == ["Q6H", "6 hours"]
    end

    test "encodes repeat pattern only" do
      assert RI.encode(%RI{repeat_pattern: "BID"}) == ["BID"]
    end

    test "encodes nil" do
      assert RI.encode(nil) == []
    end

    test "encodes empty struct" do
      assert RI.encode(%RI{}) == []
    end
  end

  describe "round-trip" do
    test "full RI round-trips" do
      components = ["Q6H", "6 hours"]
      assert components |> RI.parse() |> RI.encode() == components
    end

    test "pattern-only round-trips" do
      components = ["BID"]
      assert components |> RI.parse() |> RI.encode() == components
    end
  end
end
