defmodule HL7v2.Type.PPNTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.{PPN, FN, HD, TS, DTM}

  doctest PPN

  describe "parse/1" do
    test "parses basic fields" do
      result = PPN.parse(["12345", "Smith", "John"])
      assert result.id_number == "12345"
      assert %FN{surname: "Smith"} = result.family_name
      assert result.given_name == "John"
    end

    test "parses with assigning authority" do
      result = PPN.parse(["12345", "Smith", "John", "", "", "", "", "", "MRN&1.2.3&ISO"])
      assert %HD{namespace_id: "MRN"} = result.assigning_authority
    end

    test "parses with timestamp" do
      result = PPN.parse(List.duplicate("", 14) ++ ["20260322140000"])

      assert %TS{time: %DTM{year: 2026, month: 3, day: 22, hour: 14}} =
               result.date_time_action_performed
    end

    test "parses empty list" do
      result = PPN.parse([])
      assert result.id_number == nil
    end
  end

  describe "encode/1" do
    test "encodes basic PPN" do
      ppn = %PPN{id_number: "12345", family_name: %FN{surname: "Smith"}, given_name: "John"}
      assert PPN.encode(ppn) == ["12345", "Smith", "John"]
    end

    test "encodes nil" do
      assert PPN.encode(nil) == []
    end
  end

  describe "round-trip" do
    test "basic PPN round-trips" do
      components = ["12345", "Smith", "John"]
      assert components |> PPN.parse() |> PPN.encode() == components
    end
  end
end
