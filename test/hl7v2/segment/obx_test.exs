defmodule HL7v2.Segment.OBXTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.OBX
  alias HL7v2.Type.{CE, CWE, TS, DTM}

  describe "fields/0" do
    test "returns 19 field definitions" do
      assert length(OBX.fields()) == 19
    end
  end

  describe "segment_id/0" do
    test "returns OBX" do
      assert OBX.segment_id() == "OBX"
    end
  end

  describe "parse/1" do
    test "parses OBX with NM value type and numeric observation" do
      raw =
        build_obx_fields(%{
          0 => "1",
          1 => "NM",
          2 => ["8480-6", "Systolic BP", "LN"],
          4 => "120",
          10 => "F"
        })

      result = OBX.parse(raw)

      assert %OBX{} = result
      assert result.set_id == 1
      assert result.value_type == "NM"

      assert %CE{identifier: "8480-6", text: "Systolic BP", name_of_coding_system: "LN"} =
               result.observation_identifier

      # NM type normalizes numeric strings
      assert result.observation_value == "120"
      assert result.observation_result_status == "F"
    end

    test "parses OBX with ST value type and string observation" do
      raw =
        build_obx_fields(%{
          0 => "2",
          1 => "ST",
          2 => ["8462-4", "Diastolic BP", "LN"],
          4 => "Normal reading",
          10 => "F"
        })

      result = OBX.parse(raw)

      assert result.set_id == 2
      assert result.value_type == "ST"
      assert result.observation_value == "Normal reading"
      assert result.observation_result_status == "F"
    end

    test "CWE value type dispatches to typed CWE struct" do
      raw =
        build_obx_fields(%{
          1 => "CWE",
          4 => [["component1", "component2"]]
        })

      result = OBX.parse(raw)

      assert [%CWE{identifier: "component1", text: "component2"}] = result.observation_value
    end

    test "TX value type dispatches to typed text" do
      raw =
        build_obx_fields(%{
          1 => "TX",
          4 => "Free text observation"
        })

      result = OBX.parse(raw)

      assert result.observation_value == "Free text observation"
    end

    test "nil value_type preserves observation_value as raw" do
      raw = build_obx_fields(%{4 => "some raw value"})

      result = OBX.parse(raw)

      assert result.observation_value == "some raw value"
    end

    test "unknown value_type preserves observation_value as raw" do
      raw =
        build_obx_fields(%{
          1 => "ED",
          4 => "encapsulated data"
        })

      result = OBX.parse(raw)

      assert result.observation_value == "encapsulated data"
    end

    test "units parsed as CE" do
      raw =
        build_obx_fields(%{
          0 => "1",
          1 => "NM",
          2 => ["8480-6", "Systolic BP", "LN"],
          4 => "120",
          5 => ["mmHg", "mmHg", "UCUM"],
          10 => "F"
        })

      result = OBX.parse(raw)

      assert %CE{identifier: "mmHg", text: "mmHg", name_of_coding_system: "UCUM"} = result.units
    end

    test "date_time_of_the_observation parsed as TS" do
      raw =
        build_obx_fields(%{
          0 => "1",
          1 => "NM",
          2 => ["8480-6", "Systolic BP", "LN"],
          4 => "120",
          10 => "F",
          13 => ["20260322143000"]
        })

      result = OBX.parse(raw)

      assert %TS{time: %DTM{year: 2026, month: 3, day: 22}} = result.date_time_of_the_observation
    end

    test "parses empty list — all fields nil" do
      result = OBX.parse([])

      assert %OBX{} = result
      assert result.set_id == nil
      assert result.value_type == nil
      assert result.observation_identifier == nil
      assert result.observation_value == nil
      assert result.observation_result_status == nil
    end
  end

  describe "encode/1" do
    test "round-trip: parse then encode preserves data" do
      raw =
        build_obx_fields(%{
          0 => "1",
          1 => "NM",
          2 => ["8480-6", "Systolic BP", "LN"],
          4 => "120",
          10 => "F"
        })

      encoded = raw |> OBX.parse() |> OBX.encode()

      assert Enum.at(encoded, 0) == "1"
      assert Enum.at(encoded, 1) == "NM"
      assert Enum.at(encoded, 2) == ["8480-6", "Systolic BP", "LN"]
      # observation_sub_id at index 3 is nil -> ""
      assert Enum.at(encoded, 4) == "120"
      assert Enum.at(encoded, 10) == "F"
    end

    test "round-trip with string observation value" do
      raw =
        build_obx_fields(%{
          0 => "1",
          1 => "ST",
          2 => ["code", "text", "system"],
          4 => "some text value",
          10 => "F"
        })

      encoded = raw |> OBX.parse() |> OBX.encode()

      assert Enum.at(encoded, 4) == "some text value"
    end

    test "round-trip with CWE observation value" do
      raw =
        build_obx_fields(%{
          0 => "1",
          1 => "CWE",
          2 => ["code", "text", "system"],
          4 => ["I48.0", "Paroxysmal AFib", "I10"],
          10 => "F"
        })

      encoded = raw |> OBX.parse() |> OBX.encode()

      assert Enum.at(encoded, 4) == ["I48.0", "Paroxysmal AFib", "I10"]
    end

    test "trailing nil fields are trimmed" do
      obx = %OBX{set_id: 1, value_type: "NM"}

      encoded = OBX.encode(obx)

      assert encoded == ["1", "NM"]
    end

    test "encodes all-nil struct to empty list" do
      assert OBX.encode(%OBX{}) == []
    end
  end

  defp build_obx_fields(overrides) do
    Enum.map(0..18, fn i -> Map.get(overrides, i) end)
  end
end
