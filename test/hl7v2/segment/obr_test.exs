defmodule HL7v2.Segment.OBRTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.OBR
  alias HL7v2.Type.{CE, CNN, EI, HD, NDL, XCN, FN, TS, DTM}

  describe "fields/0" do
    test "returns 49 field definitions" do
      assert length(OBR.fields()) == 50
    end
  end

  describe "segment_id/0" do
    test "returns OBR" do
      assert OBR.segment_id() == "OBR"
    end
  end

  describe "parse/1" do
    test "parses with order info" do
      raw =
        build_obr_fields(%{
          0 => "1",
          1 => ["ORD001", "PLACER"],
          2 => ["FILL001", "FILLER"],
          3 => ["85025", "CBC", "CPT4"]
        })

      result = OBR.parse(raw)

      assert %OBR{} = result
      assert result.set_id == 1

      assert %EI{entity_identifier: "ORD001", namespace_id: "PLACER"} =
               result.placer_order_number

      assert %EI{entity_identifier: "FILL001", namespace_id: "FILLER"} =
               result.filler_order_number

      assert %CE{identifier: "85025", text: "CBC", name_of_coding_system: "CPT4"} =
               result.universal_service_identifier
    end

    test "observation_date_time parsed as TS" do
      raw =
        build_obr_fields(%{
          3 => ["85025", "CBC", "CPT4"],
          6 => ["20260315083000"]
        })

      result = OBR.parse(raw)

      assert %TS{
               time: %DTM{year: 2026, month: 3, day: 15, hour: 8, minute: 30, second: 0}
             } = result.observation_date_time
    end

    test "ordering_provider and collector_identifier parsed as XCN" do
      collector_raw = [["TECH001", "Jones"]]

      raw =
        build_obr_fields(%{
          3 => ["85025", "CBC", "CPT4"],
          9 => collector_raw,
          15 => ["Smith", "John", "Q"]
        })

      result = OBR.parse(raw)

      assert [%XCN{id_number: "TECH001", family_name: %FN{surname: "Jones"}}] =
               result.collector_identifier

      assert [%XCN{id_number: "Smith", family_name: %FN{surname: "John"}, given_name: "Q"}] =
               result.ordering_provider
    end

    test "result_status and diagnostic_serv_sect_id parsed" do
      raw =
        build_obr_fields(%{
          3 => ["85025", "CBC", "CPT4"],
          23 => "HM",
          24 => "F"
        })

      result = OBR.parse(raw)

      assert result.diagnostic_serv_sect_id == "HM"
      assert result.result_status == "F"
    end

    test "parses empty list — all fields nil" do
      result = OBR.parse([])

      assert %OBR{} = result
      assert result.set_id == nil
      assert result.placer_order_number == nil
      assert result.filler_order_number == nil
      assert result.universal_service_identifier == nil
      assert result.observation_date_time == nil
    end
  end

  describe "encode/1" do
    test "round-trip: parse then encode preserves data" do
      raw =
        build_obr_fields(%{
          0 => "1",
          1 => ["ORD001", "PLACER"],
          2 => ["FILL001", "FILLER"],
          3 => ["85025", "CBC", "CPT4"]
        })

      encoded = raw |> OBR.parse() |> OBR.encode()

      assert Enum.at(encoded, 0) == "1"
      assert Enum.at(encoded, 1) == ["ORD001", "PLACER"]
      assert Enum.at(encoded, 2) == ["FILL001", "FILLER"]
      assert Enum.at(encoded, 3) == ["85025", "CBC", "CPT4"]
    end

    test "round-trip with ordering_provider XCN" do
      raw =
        build_obr_fields(%{
          3 => ["85025", "CBC", "CPT4"],
          15 => ["DrSmith", "John"]
        })

      encoded = raw |> OBR.parse() |> OBR.encode()

      assert Enum.at(encoded, 15) == ["DrSmith", "John"]
    end

    test "trailing nil fields are trimmed" do
      obr = %OBR{set_id: 1}

      encoded = OBR.encode(obr)

      assert encoded == ["1"]
    end

    test "encodes all-nil struct to empty list" do
      assert OBR.encode(%OBR{}) == []
    end
  end

  describe "NDL fields (32-35)" do
    test "principal_result_interpreter parses as NDL (field 32)" do
      raw =
        build_obr_fields(%{
          3 => ["85025", "CBC", "CPT4"],
          31 => ["12345&Smith&John", "20260315083000", "", "ICU"]
        })

      result = OBR.parse(raw)

      assert %NDL{} = result.principal_result_interpreter

      assert %CNN{id_number: "12345", family_name: "Smith", given_name: "John"} =
               result.principal_result_interpreter.name

      assert %TS{time: %DTM{year: 2026, month: 3}} =
               result.principal_result_interpreter.start_date_time

      assert result.principal_result_interpreter.point_of_care == "ICU"
    end

    test "assistant_result_interpreter parses as repeating NDL (field 33)" do
      raw =
        build_obr_fields(%{
          3 => ["85025", "CBC", "CPT4"],
          32 => [
            ["99&Jones&Alice", "20260315090000"],
            ["88&Brown&Bob", "20260315100000"]
          ]
        })

      result = OBR.parse(raw)

      assert [%NDL{} = first, %NDL{} = second] = result.assistant_result_interpreter
      assert %CNN{id_number: "99", family_name: "Jones", given_name: "Alice"} = first.name
      assert %CNN{id_number: "88", family_name: "Brown", given_name: "Bob"} = second.name
    end

    test "technician parses as repeating NDL (field 34)" do
      raw =
        build_obr_fields(%{
          3 => ["85025", "CBC", "CPT4"],
          33 => ["55&Garcia&Maria"]
        })

      result = OBR.parse(raw)

      assert [%NDL{name: %CNN{id_number: "55", family_name: "Garcia", given_name: "Maria"}}] =
               result.technician
    end

    test "transcriptionist parses as repeating NDL (field 35)" do
      raw =
        build_obr_fields(%{
          3 => ["85025", "CBC", "CPT4"],
          34 => ["77&Lee&Pat"]
        })

      result = OBR.parse(raw)

      assert [%NDL{name: %CNN{id_number: "77", family_name: "Lee", given_name: "Pat"}}] =
               result.transcriptionist
    end

    test "NDL fields with facility HD sub-components" do
      raw =
        build_obr_fields(%{
          3 => ["85025", "CBC", "CPT4"],
          31 => ["12345&Smith&John", "", "", "ICU", "101", "A", "HOSP&1.2.3&ISO"]
        })

      result = OBR.parse(raw)

      assert %NDL{} = result.principal_result_interpreter
      assert result.principal_result_interpreter.point_of_care == "ICU"
      assert result.principal_result_interpreter.room == "101"
      assert result.principal_result_interpreter.bed == "A"

      assert %HD{namespace_id: "HOSP", universal_id: "1.2.3", universal_id_type: "ISO"} =
               result.principal_result_interpreter.facility
    end

    test "round-trip encode/parse preserves NDL fields" do
      obr = %OBR{
        universal_service_identifier: %CE{identifier: "85025", text: "CBC"},
        principal_result_interpreter: %NDL{
          name: %CNN{id_number: "12345", family_name: "Smith", given_name: "John"},
          point_of_care: "ICU"
        },
        technician: [
          %NDL{name: %CNN{id_number: "55", family_name: "Garcia"}}
        ]
      }

      encoded = OBR.encode(obr)
      parsed = OBR.parse(encoded)

      assert %NDL{} = parsed.principal_result_interpreter
      assert parsed.principal_result_interpreter.name.id_number == "12345"
      assert parsed.principal_result_interpreter.name.family_name == "Smith"
      assert parsed.principal_result_interpreter.point_of_care == "ICU"

      assert [%NDL{name: %CNN{id_number: "55", family_name: "Garcia"}}] = parsed.technician
    end
  end

  defp build_obr_fields(overrides) do
    Enum.map(0..48, fn i -> Map.get(overrides, i) end)
  end
end
