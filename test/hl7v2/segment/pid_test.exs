defmodule HL7v2.Segment.PIDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.PID
  alias HL7v2.Type.{CX, XPN, FN, HD, TS, DTM}

  describe "fields/0" do
    test "returns 39 field definitions" do
      assert length(PID.fields()) == 39
    end
  end

  describe "segment_id/0" do
    test "returns PID" do
      assert PID.segment_id() == "PID"
    end
  end

  describe "parse/1" do
    test "parses common fields" do
      raw = build_pid_fields(%{
        0 => "1",
        2 => [["12345", "", "", "MRN", "MR"]],
        4 => [["Smith", "John", "Q"]],
        6 => ["20190101"],
        7 => "M"
      })

      result = PID.parse(raw)

      assert %PID{} = result
      assert result.set_id == 1
      assert result.administrative_sex == "M"
    end

    test "patient_identifier_list: single CX" do
      raw = build_pid_fields(%{
        2 => [["12345", "", "", "MRN", "MR"]]
      })

      result = PID.parse(raw)

      assert [%CX{} = cx] = result.patient_identifier_list
      assert cx.id == "12345"
      assert cx.assigning_authority == %HD{namespace_id: "MRN"}
      assert cx.identifier_type_code == "MR"
    end

    test "patient_identifier_list: multiple CX (repeated)" do
      raw = build_pid_fields(%{
        2 => [["12345", "", "", "MRN", "MR"], ["67890", "", "", "SSN", "SS"]]
      })

      result = PID.parse(raw)

      assert [%CX{} = cx1, %CX{} = cx2] = result.patient_identifier_list
      assert cx1.id == "12345"
      assert cx1.assigning_authority == %HD{namespace_id: "MRN"}
      assert cx1.identifier_type_code == "MR"
      assert cx2.id == "67890"
      assert cx2.assigning_authority == %HD{namespace_id: "SSN"}
      assert cx2.identifier_type_code == "SS"
    end

    test "patient_name: XPN with family, given, and middle initial" do
      raw = build_pid_fields(%{
        4 => [["Smith", "John", "Q"]]
      })

      result = PID.parse(raw)

      assert [%XPN{} = xpn] = result.patient_name
      assert xpn.family_name == %FN{surname: "Smith"}
      assert xpn.given_name == "John"
      assert xpn.second_name == "Q"
    end

    test "date_time_of_birth parsed as TS" do
      raw = build_pid_fields(%{
        6 => ["20190101"]
      })

      result = PID.parse(raw)

      assert %TS{time: %DTM{year: 2019, month: 1, day: 1}} = result.date_time_of_birth
    end

    test "parses empty list — all fields nil" do
      result = PID.parse([])

      assert %PID{} = result
      assert result.set_id == nil
      assert result.patient_identifier_list == nil
      assert result.patient_name == nil
      assert result.date_time_of_birth == nil
      assert result.administrative_sex == nil
      assert result.patient_address == nil
    end

    test "parses empty string fields as nil" do
      raw = List.duplicate("", 39)

      result = PID.parse(raw)

      assert result.set_id == nil
      assert result.patient_identifier_list == nil
      assert result.administrative_sex == nil
    end
  end

  describe "encode/1" do
    test "round-trip: parse then encode preserves data" do
      raw = build_pid_fields(%{
        0 => "1",
        2 => [["12345", "", "", "MRN", "MR"]],
        4 => [["Smith", "John", "Q"]],
        6 => ["20190101"],
        7 => "M"
      })

      encoded = raw |> PID.parse() |> PID.encode()

      assert Enum.at(encoded, 0) == "1"
      assert Enum.at(encoded, 2) == ["12345", "", "", "MRN", "MR"]
      assert Enum.at(encoded, 4) == ["Smith", "John", "Q"]
      assert Enum.at(encoded, 6) == ["20190101"]
      assert Enum.at(encoded, 7) == "M"
    end

    test "round-trip with multiple patient identifiers" do
      raw = build_pid_fields(%{
        2 => [["12345", "", "", "MRN", "MR"], ["67890", "", "", "SSN", "SS"]]
      })

      encoded = raw |> PID.parse() |> PID.encode()

      assert Enum.at(encoded, 2) == [
               ["12345", "", "", "MRN", "MR"],
               ["67890", "", "", "SSN", "SS"]
             ]
    end

    test "trailing nil fields are trimmed" do
      pid = %PID{set_id: 1}

      encoded = PID.encode(pid)

      assert encoded == ["1"]
    end

    test "encodes all-nil struct to empty list" do
      assert PID.encode(%PID{}) == []
    end
  end

  # Builds a 39-position raw field list, inserting values at specified 0-indexed positions.
  defp build_pid_fields(overrides) do
    Enum.map(0..38, fn i -> Map.get(overrides, i) end)
  end
end
