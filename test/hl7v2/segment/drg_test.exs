defmodule HL7v2.Segment.DRGTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.DRG

  describe "fields/0" do
    test "returns 11 field definitions" do
      assert length(DRG.fields()) == 11
    end
  end

  describe "segment_id/0" do
    test "returns DRG" do
      assert DRG.segment_id() == "DRG"
    end
  end

  describe "parse/1" do
    test "parses diagnostic_related_group and assigned date" do
      raw = [["470", "Major Joint Replacement", "MS-DRG"], ["20260315120000"]]

      result = DRG.parse(raw)

      assert %DRG{} = result

      assert %HL7v2.Type.CE{identifier: "470", text: "Major Joint Replacement"} =
               result.diagnostic_related_group

      assert %HL7v2.Type.TS{
               time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 15, hour: 12}
             } = result.drg_assigned_date_time
    end

    test "parses approval and grouper review" do
      raw = ["", "", "Y", "01"]

      result = DRG.parse(raw)

      assert result.drg_approval_indicator == "Y"
      assert result.drg_grouper_review_code == "01"
    end

    test "parses outlier fields" do
      raw = [
        "",
        "",
        "",
        "",
        ["D", "Day Outlier"],
        "5",
        [["2500.00", "USD"]]
      ]

      result = DRG.parse(raw)

      assert %HL7v2.Type.CE{identifier: "D"} = result.outlier_type
      assert %HL7v2.Type.NM{value: "5"} = result.outlier_days
      assert %HL7v2.Type.CP{} = result.outlier_cost
    end

    test "parses drg_payor and confidential_indicator" do
      raw = List.duplicate("", 7) ++ ["MC", "", "Y"]

      result = DRG.parse(raw)

      assert result.drg_payor == "MC"
      assert result.confidential_indicator == "Y"
    end

    test "parses drg_transfer_type" do
      raw = List.duplicate("", 10) ++ ["01"]

      result = DRG.parse(raw)

      assert result.drg_transfer_type == "01"
    end

    test "parses empty list — all fields nil" do
      result = DRG.parse([])

      assert %DRG{} = result
      assert result.diagnostic_related_group == nil
      assert result.outlier_days == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [["470", "Major Joint Replacement"], ["20260315120000"], "Y"]

      encoded = raw |> DRG.parse() |> DRG.encode()
      reparsed = DRG.parse(encoded)

      assert reparsed.diagnostic_related_group.identifier == "470"
      assert reparsed.drg_approval_indicator == "Y"
    end

    test "trailing nil fields trimmed" do
      drg = %DRG{
        diagnostic_related_group: %HL7v2.Type.CE{identifier: "470"},
        drg_approval_indicator: "Y"
      }

      encoded = DRG.encode(drg)

      assert length(encoded) == 3
    end

    test "encodes all-nil struct to empty list" do
      assert DRG.encode(%DRG{}) == []
    end
  end

  describe "typed parsing integration" do
    test "ADT^A01 with DRG parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01|1|P|2.5.1\r" <>
          "EVN|A01|20260322\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|I\r" <>
          "DRG|470^Major Joint Replacement|20260315120000|Y\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      drg = Enum.find(msg.segments, &is_struct(&1, DRG))
      assert %DRG{drg_approval_indicator: "Y"} = drg
      assert drg.diagnostic_related_group.identifier == "470"
    end
  end
end
