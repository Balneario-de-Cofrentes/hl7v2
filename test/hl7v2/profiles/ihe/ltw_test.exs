defmodule HL7v2.Profiles.IHE.LTWTest do
  use ExUnit.Case, async: true

  alias HL7v2.Profile
  alias HL7v2.Profiles.IHE.LTW
  alias HL7v2.Validation.ProfileRules

  # --- Fixtures ---------------------------------------------------------

  # Helper: build an OBR segment where OBR-N fields can be set
  # explicitly by position without manual pipe-counting.
  defp obr(values) when is_list(values) do
    defaults = for _ <- 1..25, do: ""

    merged =
      Enum.reduce(values, defaults, fn {pos, v}, acc -> List.replace_at(acc, pos - 1, v) end)

    "OBR|" <> Enum.join(merged, "|") <> "\r"
  end

  defp orc(values) when is_list(values) do
    defaults = for _ <- 1..10, do: ""

    merged =
      Enum.reduce(values, defaults, fn {pos, v}, acc -> List.replace_at(acc, pos - 1, v) end)

    "ORC|" <> Enum.join(merged, "|") <> "\r"
  end

  @lab_1_msh_pid "MSH|^~\\&|HIS|HOSP|LAB|HOSP|20260409120000||OML^O21^OML_O21|MSG001|P|2.5.1\r" <>
                   "PID|1||12345^^^HOSP_MRN&1.2.3&ISO^MR||Smith^John\r" <> "PV1|1|U\r"

  # Valid LAB-1 OML^O21 new order. ORC-1=NW, ORC-9 populated, TQ1 present,
  # OBR-2/4/16 populated. ORC-7 intentionally blank (use TQ1 instead).
  def valid_lab_1 do
    @lab_1_msh_pid <>
      orc([{1, "NW"}, {2, "ORD001"}, {9, "20260409120000"}]) <>
      "TQ1|1\r" <>
      obr([
        {1, "1"},
        {2, "ORD001"},
        {4, "CBC^Complete Blood Count^LN"},
        {16, "ORD^Ordering^MD"}
      ])
  end

  # LAB-1 with ORC-7 populated (forbidden).
  def lab_1_orc_7 do
    @lab_1_msh_pid <>
      orc([{1, "NW"}, {2, "ORD001"}, {7, "^^^20260410"}, {9, "20260409120000"}]) <>
      obr([
        {1, "1"},
        {2, "ORD001"},
        {4, "CBC^Complete Blood Count^LN"},
        {16, "ORD^Ordering^MD"}
      ])
  end

  # LAB-1 with invalid ORC-1 value.
  def lab_1_bad_orc_1 do
    @lab_1_msh_pid <>
      orc([{1, "QQ"}, {2, "ORD001"}, {9, "20260409120000"}]) <>
      obr([
        {1, "1"},
        {2, "ORD001"},
        {4, "CBC^Complete Blood Count^LN"},
        {16, "ORD^Ordering^MD"}
      ])
  end

  @lab_3_msh_pid "MSH|^~\\&|LAB|HOSP|HIS|HOSP|20260409140000||ORU^R01^ORU_R01|MSG004|P|2.5.1\r" <>
                   "PID|1||12345^^^HOSP_MRN&1.2.3&ISO^MR||Smith^John\r" <> "PV1|1|U\r"

  # Valid LAB-3 ORU^R01. OBR-3 = filler order, OBR-4 = test, OBR-25 = F.
  def valid_lab_3 do
    @lab_3_msh_pid <>
      "ORC|RE|ORD001|RESULT001\r" <>
      obr([
        {1, "1"},
        {2, "ORD001"},
        {3, "RESULT001"},
        {4, "CBC^Complete Blood Count^LN"},
        {16, "ORD^Ordering^MD"},
        {25, "F"}
      ]) <>
      "OBX|1|NM|WBC^White Blood Cell^LN||7.5|10*3/uL|4.0-11.0|N|||F\r"
  end

  def lab_3_obx_11_u do
    @lab_3_msh_pid <>
      "ORC|RE|ORD001|RESULT001\r" <>
      obr([
        {1, "1"},
        {2, "ORD001"},
        {3, "RESULT001"},
        {4, "CBC^Complete Blood Count^LN"},
        {16, "ORD^Ordering^MD"},
        {25, "F"}
      ]) <>
      "OBX|1|NM|WBC^White Blood Cell^LN||7.5|10*3/uL|4.0-11.0|N|||U\r"
  end

  def lab_3_bad_obr_25 do
    @lab_3_msh_pid <>
      "ORC|RE|ORD001|RESULT001\r" <>
      obr([
        {1, "1"},
        {2, "ORD001"},
        {3, "RESULT001"},
        {4, "CBC^Complete Blood Count^LN"},
        {16, "ORD^Ordering^MD"},
        {25, "Z"}
      ]) <>
      "OBX|1|NM|WBC^White Blood Cell^LN||7.5|10*3/uL|4.0-11.0|N|||F\r"
  end

  defp parse!(wire) do
    {:ok, msg} = HL7v2.parse(wire, mode: :typed)
    msg
  end

  # --- LAB-1 Placer Order Management ------------------------------------

  describe "lab_1_placer_oml_o21/0" do
    test "metadata" do
      profile = LTW.lab_1_placer_oml_o21()
      assert profile.name == "IHE_LAB-1_OML_O21"
      assert profile.message_type == {"OML", "O21"}
      assert profile.version == "2.5.1"
    end

    test "forbids ORC-7 and OBR-5/6/8/15/22/27" do
      profile = LTW.lab_1_placer_oml_o21()

      assert MapSet.member?(profile.forbidden_fields, {"ORC", 7})
      assert MapSet.member?(profile.forbidden_fields, {"OBR", 5})
      assert MapSet.member?(profile.forbidden_fields, {"OBR", 6})
      assert MapSet.member?(profile.forbidden_fields, {"OBR", 8})
      assert MapSet.member?(profile.forbidden_fields, {"OBR", 15})
      assert MapSet.member?(profile.forbidden_fields, {"OBR", 22})
      assert MapSet.member?(profile.forbidden_fields, {"OBR", 27})
    end

    test "valid OML^O21 passes" do
      msg = parse!(valid_lab_1())
      assert ProfileRules.check(msg, LTW.lab_1_placer_oml_o21()) == []
    end

    test "populated ORC-7 fires :forbid_field" do
      msg = parse!(lab_1_orc_7())
      errors = ProfileRules.check(msg, LTW.lab_1_placer_oml_o21())

      assert Enum.any?(errors, fn e ->
               e.rule == :forbid_field and e.location == "ORC"
             end)
    end

    test "invalid ORC-1 fires :value_constraint" do
      msg = parse!(lab_1_bad_orc_1())
      errors = ProfileRules.check(msg, LTW.lab_1_placer_oml_o21())

      assert Enum.any?(errors, fn e ->
               e.rule == :value_constraint and e.location == "ORC"
             end)
    end

    test "missing PV1 segment fires :require_segment (regression: iter-7 audit #2)" do
      profile = LTW.lab_1_placer_oml_o21()
      assert "PV1" in Profile.required_segments?(profile)

      no_pv1 =
        "MSH|^~\\&|HIS|HOSP|LAB|HOSP|20260409120000||OML^O21^OML_O21|MSG|P|2.5.1\r" <>
          "PID|1||12345^^^HOSP_MRN&1.2.3&ISO^MR||Smith^John\r" <>
          orc([{1, "NW"}, {2, "ORD001"}, {9, "20260409120000"}]) <>
          obr([{1, "1"}, {2, "ORD001"}, {4, "CBC^^LN"}, {16, "ORD^^MD"}])

      msg = parse!(no_pv1)
      errors = ProfileRules.check(msg, profile)

      assert Enum.any?(errors, fn e ->
               e.rule == :require_segment and e.location == "PV1"
             end)
    end
  end

  # --- LAB-3 Order Results Management -----------------------------------

  describe "lab_3_results_oru_r01/0" do
    test "metadata" do
      profile = LTW.lab_3_results_oru_r01()
      assert profile.name == "IHE_LAB-3_ORU_R01"
      assert profile.message_type == {"ORU", "R01"}
      assert profile.version == "2.5.1"
    end

    test "requires OBR-3, OBR-4, OBR-25, OBX-1/3/11" do
      profile = LTW.lab_3_results_oru_r01()
      assert profile.required_fields[{"OBR", 3}] == :required
      assert profile.required_fields[{"OBR", 4}] == :required
      assert profile.required_fields[{"OBR", 25}] == :required
      assert profile.required_fields[{"OBX", 1}] == :required
      assert profile.required_fields[{"OBX", 3}] == :required
      assert profile.required_fields[{"OBX", 11}] == :required
    end

    test "forbids OBX-9/10/12" do
      profile = LTW.lab_3_results_oru_r01()
      assert MapSet.member?(profile.forbidden_fields, {"OBX", 9})
      assert MapSet.member?(profile.forbidden_fields, {"OBX", 10})
      assert MapSet.member?(profile.forbidden_fields, {"OBX", 12})
    end

    test "valid ORU^R01 passes" do
      msg = parse!(valid_lab_3())
      assert ProfileRules.check(msg, LTW.lab_3_results_oru_r01()) == []
    end

    test "OBX-11 = 'U' fires :value_constraint" do
      msg = parse!(lab_3_obx_11_u())
      errors = ProfileRules.check(msg, LTW.lab_3_results_oru_r01())

      assert Enum.any?(errors, fn e ->
               e.rule == :value_constraint and e.location == "OBX"
             end)
    end

    test "invalid OBR-25 fires :value_constraint" do
      msg = parse!(lab_3_bad_obr_25())
      errors = ProfileRules.check(msg, LTW.lab_3_results_oru_r01())

      assert Enum.any?(errors, fn e ->
               e.rule == :value_constraint and e.location == "OBR"
             end)
    end

    test "missing PV1 segment fires :require_segment (regression: iter-7 audit #2)" do
      profile = LTW.lab_3_results_oru_r01()
      assert "PV1" in Profile.required_segments?(profile)
    end
  end

  # --- catalog ----------------------------------------------------------

  describe "all/0" do
    test "returns 2 LTW profiles" do
      catalog = LTW.all()

      assert map_size(catalog) == 2
      assert Map.has_key?(catalog, "LAB-1")
      assert Map.has_key?(catalog, "LAB-3")

      for {_code, profile} <- catalog do
        assert %Profile{} = profile
        assert profile.version == "2.5.1"
      end
    end
  end
end
