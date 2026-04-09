defmodule HL7v2.Profiles.IHE.RadSwfTest do
  use ExUnit.Case, async: true

  alias HL7v2.Profiles.IHE.RadSwf
  alias HL7v2.Validation.ProfileRules

  # --- Fixtures ---------------------------------------------------------

  defp seg(id, max_pos, values) do
    defaults = for _ <- 1..max_pos, do: ""

    merged =
      Enum.reduce(values, defaults, fn {pos, v}, acc -> List.replace_at(acc, pos - 1, v) end)

    "#{id}|" <> Enum.join(merged, "|") <> "\r"
  end

  defp pv1(values), do: seg("PV1", 17, values)
  defp orc(values), do: seg("ORC", 10, values)

  @rad_1_msh_pid_evn "MSH|^~\\&|HIS|HOSP|RIS|IMG|20260409120000||ADT^A01|MSG001|P|2.3.1\r" <>
                       "EVN||20260409120000\r" <>
                       "PID|1||12345^^^HOSP_MRN&1.2.3&ISO^MR||Smith^John||19800315|M\r"

  # Valid RAD-1 v2.3.1 A01: all required PV1 fields populated.
  def valid_rad_1 do
    @rad_1_msh_pid_evn <>
      pv1([
        {1, "1"},
        {2, "I"},
        {3, "ICU^101^A"},
        {7, "ATT001^Attending^MD"},
        {10, "RAD"},
        {17, "ADM001^Admitting^MD"}
      ])
  end

  # RAD-1 with no PV1-7 (Attending Doctor missing).
  def rad_1_no_attending do
    @rad_1_msh_pid_evn <>
      pv1([
        {1, "1"},
        {2, "I"},
        {3, "ICU^101^A"},
        {10, "RAD"},
        {17, "ADM001^Admitting^MD"}
      ])
  end

  # A v2.5 A01 — should be silently skipped by the v2.3.1 RAD-1 profile.
  @rad_1_v25 "MSH|^~\\&|HIS|HOSP|RIS|IMG|20260409120000||ADT^A01^ADT_A01|MSG003|P|2.5\r" <>
               "EVN||20260409120000\r" <>
               "PID|1||12345^^^HOSP_MRN&1.2.3&ISO^MR||Smith^John||19800315|M\r" <>
               "PV1|1|I|ICU^101^A\r"

  @rad_4_msh_pid "MSH|^~\\&|DSS|IMG|PACS|IMG|20260409120000||OMI^O23^OMI_O23|MSG004|P|2.5.1\r" <>
                   "PID|1||12345^^^HOSP_MRN&1.2.3&ISO^MR||Smith^John||19800315|M\r" <>
                   "PV1|1|I\r"

  # Valid RAD-4 OMI^O23 v2.5.1. ORC-1=NW, ORC-5=SC, TQ1-7 populated,
  # IPC carries Accession, Procedure ID, Study UID, SPS ID, Modality.
  def valid_rad_4 do
    @rad_4_msh_pid <>
      orc([{1, "NW"}, {2, "ORD001"}, {3, "FILL001"}, {5, "SC"}]) <>
      "TQ1|1||||||20260409130000\r" <>
      "OBR|1|ORD001|FILL001|CT^Chest CT^LN\r" <>
      "IPC|ACC001|REQ001|1.2.3.4.5.6.7.8.9|SPS001|CT\r"
  end

  # RAD-4 with ORC-1 = CA (should be NW for new scheduling).
  def rad_4_bad_orc_1 do
    @rad_4_msh_pid <>
      orc([{1, "CA"}, {2, "ORD001"}, {3, "FILL001"}, {5, "SC"}]) <>
      "TQ1|1||||||20260409130000\r" <>
      "OBR|1|ORD001|FILL001|CT^Chest CT^LN\r" <>
      "IPC|ACC001|REQ001|1.2.3.4.5.6.7.8.9|SPS001|CT\r"
  end

  # RAD-4 missing IPC-3 Study Instance UID.
  def rad_4_no_study_uid do
    @rad_4_msh_pid <>
      orc([{1, "NW"}, {2, "ORD001"}, {3, "FILL001"}, {5, "SC"}]) <>
      "TQ1|1||||||20260409130000\r" <>
      "OBR|1|ORD001|FILL001|CT^Chest CT^LN\r" <>
      "IPC|ACC001|REQ001||SPS001|CT\r"
  end

  defp parse!(wire) do
    {:ok, msg} = HL7v2.parse(wire, mode: :typed)
    msg
  end

  # --- RAD-1 Patient Registration (v2.3.1) ------------------------------

  describe "rad_1_registration_a01/0" do
    test "metadata identifies v2.3.1 profile" do
      profile = RadSwf.rad_1_registration_a01()
      assert profile.name == "IHE_RAD-1_ADT_A01"
      assert profile.message_type == {"ADT", "A01"}
      assert profile.version == "2.3.1"
    end

    test "requires PV1-3, PV1-7, PV1-10, PV1-17 for A01" do
      profile = RadSwf.rad_1_registration_a01()
      assert profile.required_fields[{"PV1", 3}] == :required
      assert profile.required_fields[{"PV1", 7}] == :required
      assert profile.required_fields[{"PV1", 10}] == :required
      assert profile.required_fields[{"PV1", 17}] == :required
    end

    test "requires PID-8 Administrative Sex" do
      profile = RadSwf.rad_1_registration_a01()
      assert profile.required_fields[{"PID", 8}] == :required
    end

    test "valid v2.3.1 RAD-1 passes" do
      msg = parse!(valid_rad_1())
      assert ProfileRules.check(msg, RadSwf.rad_1_registration_a01()) == []
    end

    test "missing PV1-7 fires :require_field" do
      msg = parse!(rad_1_no_attending())
      errors = ProfileRules.check(msg, RadSwf.rad_1_registration_a01())

      assert Enum.any?(errors, fn e ->
               e.rule == :require_field and e.location == "PV1" and
                 e.profile == "IHE_RAD-1_ADT_A01"
             end)
    end

    test "v2.5 A01 is silently skipped by the v2.3.1 profile" do
      msg = parse!(@rad_1_v25)
      assert ProfileRules.check(msg, RadSwf.rad_1_registration_a01()) == []
    end
  end

  # --- RAD-4 Procedure Scheduled (v2.5.1 OMI^O23) -----------------------

  describe "rad_4_procedure_scheduled_omi/0" do
    test "metadata identifies v2.5.1 OMI^O23 profile" do
      profile = RadSwf.rad_4_procedure_scheduled_omi()
      assert profile.name == "IHE_RAD-4_OMI_O23"
      assert profile.message_type == {"OMI", "O23"}
      assert profile.version == "2.5.1"
    end

    test "requires all 5 IPC fields (Accession, ProcedureID, StudyUID, SPSID, Modality)" do
      profile = RadSwf.rad_4_procedure_scheduled_omi()
      assert profile.required_fields[{"IPC", 1}] == :required
      assert profile.required_fields[{"IPC", 2}] == :required
      assert profile.required_fields[{"IPC", 3}] == :required
      assert profile.required_fields[{"IPC", 4}] == :required
      assert profile.required_fields[{"IPC", 5}] == :required
    end

    test "forbids deprecated ORC-7 and OBR-15/27" do
      profile = RadSwf.rad_4_procedure_scheduled_omi()
      assert MapSet.member?(profile.forbidden_fields, {"ORC", 7})
      assert MapSet.member?(profile.forbidden_fields, {"OBR", 15})
      assert MapSet.member?(profile.forbidden_fields, {"OBR", 27})
    end

    test "valid RAD-4 OMI passes" do
      msg = parse!(valid_rad_4())
      assert ProfileRules.check(msg, RadSwf.rad_4_procedure_scheduled_omi()) == []
    end

    test "ORC-1 = 'CA' fires :value_constraint" do
      msg = parse!(rad_4_bad_orc_1())
      errors = ProfileRules.check(msg, RadSwf.rad_4_procedure_scheduled_omi())

      assert Enum.any?(errors, fn e ->
               e.rule == :value_constraint and e.location == "ORC"
             end)
    end

    test "missing IPC-3 Study UID fires :require_field" do
      msg = parse!(rad_4_no_study_uid())
      errors = ProfileRules.check(msg, RadSwf.rad_4_procedure_scheduled_omi())

      assert Enum.any?(errors, fn e ->
               e.rule == :require_field and e.location == "IPC" and
                 e.profile == "IHE_RAD-4_OMI_O23"
             end)
    end
  end

  # --- catalog ----------------------------------------------------------

  describe "all/0" do
    test "returns 2 RAD-SWF profiles" do
      catalog = RadSwf.all()

      assert map_size(catalog) == 2
      assert Map.has_key?(catalog, "RAD-1")
      assert Map.has_key?(catalog, "RAD-4")
    end

    test "RAD-1 is v2.3.1, RAD-4 is v2.5.1" do
      catalog = RadSwf.all()
      assert catalog["RAD-1"].version == "2.3.1"
      assert catalog["RAD-4"].version == "2.5.1"
    end
  end
end
