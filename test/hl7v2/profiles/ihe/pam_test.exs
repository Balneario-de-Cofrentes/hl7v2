defmodule HL7v2.Profiles.IHE.PAMTest do
  use ExUnit.Case, async: true

  alias HL7v2.Profile
  alias HL7v2.Profiles.IHE.PAM
  alias HL7v2.Validation.ProfileRules

  # --- Fixtures ---------------------------------------------------------

  # A valid ITI-31 A01 that should pass the profile. Includes MSH, EVN,
  # PID (with assigning authority), PV1 (patient class I + location).
  @valid_a01 "MSH|^~\\&|HIS|HOSP|PHAOS|VNA|20260409120000||ADT^A01^ADT_A01|MSG001|P|2.5\r" <>
               "EVN||20260409120000\r" <>
               "PID|1||12345^^^HOSP_MRN&1.2.3&ISO^MR||Smith^John^M||19800315|M\r" <>
               "PV1|1|I|ICU^101^A^^^HOSP\r"

  # A valid ITI-31 A03 discharge — no PV1-3 required, but PV1-2 still R.
  @valid_a03 "MSH|^~\\&|HIS|HOSP|PHAOS|VNA|20260409120000||ADT^A03^ADT_A01|MSG002|P|2.5\r" <>
               "EVN||20260409180000\r" <>
               "PID|1||12345^^^HOSP_MRN&1.2.3&ISO^MR||Smith^John^M||19800315|M\r" <>
               "PV1|1|I\r"

  # A valid ITI-31 A40 merge — MRG segment present, no PV1.
  @valid_a40 "MSH|^~\\&|HIS|HOSP|PHAOS|VNA|20260409120000||ADT^A40^ADT_A39|MSG003|P|2.5\r" <>
               "EVN||20260409120000\r" <>
               "PID|1||99999^^^HOSP_MRN&1.2.3&ISO^MR||Smith^John\r" <>
               "MRG|12345^^^HOSP_MRN&1.2.3&ISO^MR\r"

  # A valid ITI-30 A28 (no visit) — PV1-2 pinned to N.
  @valid_a28 "MSH|^~\\&|HIS|HOSP|PHAOS|VNA|20260409120000||ADT^A28^ADT_A05|MSG004|P|2.5\r" <>
               "EVN||20260409120000\r" <>
               "PID|1||12345^^^HOSP_MRN&1.2.3&ISO^MR||Smith^John\r" <>
               "PV1|1|N\r"

  # A03 that sets MSH-8 (Security) — IHE forbids this.
  @a01_with_security "MSH|^~\\&|HIS|HOSP|PHAOS|VNA|20260409120000|SECURE|ADT^A01^ADT_A01|MSG005|P|2.5\r" <>
                       "EVN||20260409120000\r" <>
                       "PID|1||12345^^^HOSP_MRN&1.2.3&ISO^MR||Smith^John\r" <>
                       "PV1|1|I|ICU^101^A^^^HOSP\r"

  # A01 missing PV1-3 — should fire :require_field.
  @a01_missing_pv1_3 "MSH|^~\\&|HIS|HOSP|PHAOS|VNA|20260409120000||ADT^A01^ADT_A01|MSG006|P|2.5\r" <>
                       "EVN||20260409120000\r" <>
                       "PID|1||12345^^^HOSP_MRN&1.2.3&ISO^MR||Smith^John\r" <>
                       "PV1|1|I\r"

  # A01 whose PID-3 has no assigning authority — should fire the
  # :pid3_assigning_authority custom rule.
  @a01_no_aa "MSH|^~\\&|HIS|HOSP|PHAOS|VNA|20260409120000||ADT^A01^ADT_A01|MSG007|P|2.5\r" <>
               "EVN||20260409120000\r" <>
               "PID|1||12345||Smith^John\r" <>
               "PV1|1|I|ICU^101^A^^^HOSP\r"

  # A28 with PV1-2=I (not N) — should fire :value_constraint.
  @a28_wrong_class "MSH|^~\\&|HIS|HOSP|PHAOS|VNA|20260409120000||ADT^A28^ADT_A05|MSG008|P|2.5\r" <>
                     "EVN||20260409120000\r" <>
                     "PID|1||12345^^^HOSP_MRN&1.2.3&ISO^MR||Smith^John\r" <>
                     "PV1|1|I\r"

  # A01 in v2.3.1 — should NOT trigger the v2.5 profile at all.
  @a01_v231 "MSH|^~\\&|HIS|HOSP|PHAOS|VNA|20260409120000||ADT^A01^ADT_A01|MSG009|P|2.3.1\r" <>
              "EVN||20260409120000\r" <>
              "PID|1||12345^^^MRN||Smith^John\r" <>
              "PV1|1|I|ICU^101\r"

  defp parse!(wire) do
    {:ok, msg} = HL7v2.parse(wire, mode: :typed)
    msg
  end

  defp profile_errors_only(errors, profile_name) do
    Enum.filter(errors, &(&1.profile == profile_name))
  end

  # --- ITI-31 ADT^A01 ---------------------------------------------------

  describe "iti_31_adt_a01/0" do
    test "returns a Profile struct with expected metadata" do
      profile = PAM.iti_31_adt_a01()

      assert %Profile{} = profile
      assert profile.name == "IHE_ITI-31_ADT_A01"
      assert profile.message_type == {"ADT", "A01"}
      assert profile.version == "2.5"
      assert profile.description =~ "Admit Inpatient"
    end

    test "encodes the documented rule set" do
      profile = PAM.iti_31_adt_a01()

      required = Profile.required_segments?(profile)
      assert "MSH" in required
      assert "EVN" in required
      assert "PID" in required
      assert "PV1" in required

      assert profile.required_fields[{"MSH", 9}] == :required
      assert profile.required_fields[{"EVN", 2}] == :required
      assert profile.required_fields[{"PID", 3}] == :required
      assert profile.required_fields[{"PID", 5}] == :required
      assert profile.required_fields[{"PV1", 2}] == :required
      assert profile.required_fields[{"PV1", 3}] == :required

      assert MapSet.member?(profile.forbidden_fields, {"MSH", 8})
      assert MapSet.member?(profile.forbidden_fields, {"EVN", 1})

      assert Enum.any?(profile.custom_rules, fn {rule, _} ->
               rule == :pid3_assigning_authority
             end)
    end

    test "applies only to ADT^A01" do
      profile = PAM.iti_31_adt_a01()

      assert Profile.applies_to?(profile, {"ADT", "A01"})
      refute Profile.applies_to?(profile, {"ADT", "A08"})
      refute Profile.applies_to?(profile, {"ORU", "R01"})
    end

    test "a valid v2.5 A01 wire message passes the profile" do
      msg = parse!(@valid_a01)
      assert ProfileRules.check(msg, PAM.iti_31_adt_a01()) == []
    end

    test "MSH-8 Security populated triggers :forbid_field" do
      msg = parse!(@a01_with_security)
      errors = ProfileRules.check(msg, PAM.iti_31_adt_a01())

      assert Enum.any?(errors, fn e ->
               e.rule == :forbid_field and e.location == "MSH" and
                 e.profile == "IHE_ITI-31_ADT_A01"
             end)
    end

    test "missing PV1-3 triggers :require_field" do
      msg = parse!(@a01_missing_pv1_3)
      errors = ProfileRules.check(msg, PAM.iti_31_adt_a01())

      assert Enum.any?(errors, fn e ->
               e.rule == :require_field and e.location == "PV1" and
                 e.profile == "IHE_ITI-31_ADT_A01"
             end)
    end

    test "PID-3 without Assigning Authority triggers :pid3_assigning_authority" do
      msg = parse!(@a01_no_aa)
      errors = ProfileRules.check(msg, PAM.iti_31_adt_a01())

      aa_error =
        Enum.find(errors, fn e ->
          e.rule == :pid3_assigning_authority and e.location == "PID"
        end)

      assert aa_error != nil
      assert aa_error.message =~ "Assigning Authority"
      assert aa_error.profile == "IHE_ITI-31_ADT_A01"
    end

    test "v2.3.1 A01 is silently skipped by the v2.5 profile" do
      msg = parse!(@a01_v231)
      assert ProfileRules.check(msg, PAM.iti_31_adt_a01()) == []
    end

    test "integrates with HL7v2.validate/2" do
      msg = parse!(@valid_a01)

      case HL7v2.validate(msg, profile: PAM.iti_31_adt_a01()) do
        :ok ->
          :ok

        {:ok, warnings} ->
          refute Enum.any?(warnings, &(Map.get(&1, :profile) == "IHE_ITI-31_ADT_A01"))

        {:error, errors} ->
          refute Enum.any?(errors, &(Map.get(&1, :profile) == "IHE_ITI-31_ADT_A01"))
      end
    end
  end

  # --- ITI-31 ADT^A04 ---------------------------------------------------

  describe "iti_31_adt_a04/0" do
    test "returns a Profile struct with expected metadata" do
      profile = PAM.iti_31_adt_a04()

      assert profile.name == "IHE_ITI-31_ADT_A04"
      assert profile.message_type == {"ADT", "A04"}
      assert profile.version == "2.5"
    end

    test "requires PV1-3 like A01" do
      profile = PAM.iti_31_adt_a04()
      assert profile.required_fields[{"PV1", 3}] == :required
    end
  end

  # --- ITI-31 ADT^A08 ---------------------------------------------------

  describe "iti_31_adt_a08/0" do
    test "returns a Profile struct with expected metadata" do
      profile = PAM.iti_31_adt_a08()

      assert profile.name == "IHE_ITI-31_ADT_A08"
      assert profile.message_type == {"ADT", "A08"}
      assert profile.version == "2.5"
    end
  end

  # --- ITI-31 ADT^A03 ---------------------------------------------------

  describe "iti_31_adt_a03/0" do
    test "returns a Profile struct with expected metadata" do
      profile = PAM.iti_31_adt_a03()

      assert profile.name == "IHE_ITI-31_ADT_A03"
      assert profile.message_type == {"ADT", "A03"}
    end

    test "does not require PV1-3 (discharge)" do
      profile = PAM.iti_31_adt_a03()
      refute Map.has_key?(profile.required_fields, {"PV1", 3})
      assert profile.required_fields[{"PV1", 2}] == :required
    end

    test "valid A03 discharge (no PV1-3) passes" do
      msg = parse!(@valid_a03)

      assert profile_errors_only(
               ProfileRules.check(msg, PAM.iti_31_adt_a03()),
               "IHE_ITI-31_ADT_A03"
             ) == []
    end
  end

  # --- ITI-31 ADT^A40 ---------------------------------------------------

  describe "iti_31_adt_a40/0" do
    test "returns a Profile struct with expected metadata" do
      profile = PAM.iti_31_adt_a40()

      assert profile.name == "IHE_ITI-31_ADT_A40"
      assert profile.message_type == {"ADT", "A40"}
    end

    test "requires MRG and forbids PV1" do
      profile = PAM.iti_31_adt_a40()
      assert "MRG" in Profile.required_segments?(profile)
      assert "PV1" in Profile.forbidden_segments?(profile)
      assert profile.required_fields[{"MRG", 1}] == :required
    end

    test "valid A40 merge passes" do
      msg = parse!(@valid_a40)
      assert ProfileRules.check(msg, PAM.iti_31_adt_a40()) == []
    end
  end

  # --- ITI-30 ADT^A28 ---------------------------------------------------

  describe "iti_30_adt_a28/0" do
    test "returns a Profile struct with expected metadata" do
      profile = PAM.iti_30_adt_a28()

      assert profile.name == "IHE_ITI-30_ADT_A28"
      assert profile.message_type == {"ADT", "A28"}
      assert profile.version == "2.5"
    end

    test "pins PV1-2 to 'N' via a value constraint" do
      profile = PAM.iti_30_adt_a28()
      assert Map.has_key?(profile.value_constraints, {"PV1", 2})
    end

    test "valid A28 with PV1-2=N passes" do
      msg = parse!(@valid_a28)
      assert ProfileRules.check(msg, PAM.iti_30_adt_a28()) == []
    end

    test "A28 with PV1-2=I triggers :value_constraint" do
      msg = parse!(@a28_wrong_class)
      errors = ProfileRules.check(msg, PAM.iti_30_adt_a28())

      assert Enum.any?(errors, fn e ->
               e.rule == :value_constraint and e.location == "PV1" and
                 e.profile == "IHE_ITI-30_ADT_A28"
             end)
    end
  end

  # --- ITI-30 ADT^A31 ---------------------------------------------------

  describe "iti_30_adt_a31/0" do
    test "returns a Profile struct with expected metadata" do
      profile = PAM.iti_30_adt_a31()

      assert profile.name == "IHE_ITI-30_ADT_A31"
      assert profile.message_type == {"ADT", "A31"}
      assert profile.version == "2.5"
    end

    test "pins PV1-2 to 'N' like A28" do
      profile = PAM.iti_30_adt_a31()
      assert Map.has_key?(profile.value_constraints, {"PV1", 2})
    end
  end

  # --- catalog ----------------------------------------------------------

  describe "all/0" do
    test "returns all 7 PAM profiles keyed by IHE transaction code" do
      catalog = PAM.all()

      assert map_size(catalog) == 7
      assert Map.has_key?(catalog, "ITI-31.A01")
      assert Map.has_key?(catalog, "ITI-31.A04")
      assert Map.has_key?(catalog, "ITI-31.A08")
      assert Map.has_key?(catalog, "ITI-31.A03")
      assert Map.has_key?(catalog, "ITI-31.A40")
      assert Map.has_key?(catalog, "ITI-30.A28")
      assert Map.has_key?(catalog, "ITI-30.A31")

      for {_code, profile} <- catalog do
        assert %Profile{} = profile
        assert profile.version == "2.5"
      end
    end
  end
end
