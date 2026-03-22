defmodule HL7v2.Type.JCCTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.JCC

  doctest JCC

  describe "parse/1" do
    test "parses job code and class" do
      result = JCC.parse(["NURSE", "FT"])
      assert result.job_code == "NURSE"
      assert result.job_class == "FT"
    end

    test "parses job code only" do
      result = JCC.parse(["ADMIN"])
      assert result.job_code == "ADMIN"
      assert result.job_class == nil
    end

    test "parses empty list" do
      result = JCC.parse([])
      assert result.job_code == nil
      assert result.job_class == nil
    end
  end

  describe "encode/1" do
    test "encodes full JCC" do
      assert JCC.encode(%JCC{job_code: "NURSE", job_class: "FT"}) == ["NURSE", "FT"]
    end

    test "encodes job code only" do
      assert JCC.encode(%JCC{job_code: "ADMIN"}) == ["ADMIN"]
    end

    test "encodes nil" do
      assert JCC.encode(nil) == []
    end

    test "encodes empty struct" do
      assert JCC.encode(%JCC{}) == []
    end
  end

  describe "round-trip" do
    test "full JCC round-trips" do
      components = ["NURSE", "FT"]
      assert components |> JCC.parse() |> JCC.encode() == components
    end

    test "code-only round-trips" do
      components = ["ADMIN"]
      assert components |> JCC.parse() |> JCC.encode() == components
    end
  end
end
