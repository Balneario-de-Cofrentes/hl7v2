defmodule HL7v2.Profiles.ExamplesTest do
  use ExUnit.Case, async: true

  alias HL7v2.Profile
  alias HL7v2.Profiles.Examples
  alias HL7v2.Validation.ProfileRules

  # --- Fixtures ---------------------------------------------------------

  # Minimal ADT_A01: no NK1, no DG1, PID-18 blank, PV1-2 = "I", PV1-3 present.
  # Should trigger errors for NK1 (require_segment), DG1 (cardinality), and
  # PID-18 (require_field).
  @minimal_adt_wire "MSH|^~\\&|HIS|HOSP|PHAOS|VNA|20260409120000||ADT^A01^ADT_A01|MSG001|P|2.5.1\r" <>
                      "EVN|A01|20260409120000\r" <>
                      "PID|1||12345^^^MRN||Smith^John^M||19800315|M\r" <>
                      "PV1|1|I|ICU^101^A^^^HOSP\r"

  # Full ADT_A01 satisfying every rule in the hospital profile. Segment order
  # follows the ADT_A01 structure (PID, NK1, PV1, DG1).
  @full_adt_wire "MSH|^~\\&|HIS|HOSP|PHAOS|VNA|20260409120000||ADT^A01^ADT_A01|MSG002|P|2.5.1\r" <>
                   "EVN|A01|20260409120000\r" <>
                   "PID|1||12345^^^MRN||Smith^John^M||19800315|M||||||||||ACC12345\r" <>
                   "NK1|1|Smith^Jane|SPO\r" <>
                   "PV1|1|I|ICU^101^A^^^HOSP\r" <>
                   "DG1|1||J18.9^Pneumonia^ICD10|||A\r"

  # ADT_A01 with an invalid patient_class — should trigger a value_constraint error.
  @bad_patient_class_wire "MSH|^~\\&|HIS|HOSP|PHAOS|VNA|20260409120000||ADT^A01^ADT_A01|MSG003|P|2.5.1\r" <>
                            "EVN|A01|20260409120000\r" <>
                            "PID|1||12345^^^MRN||Smith^John^M||19800315|M||||||||||ACC12345\r" <>
                            "NK1|1|Smith^Jane|SPO\r" <>
                            "PV1|1|X|ICU^101^A^^^HOSP\r" <>
                            "DG1|1||J18.9^Pneumonia^ICD10|||A\r"

  # ORU_R01 without an OBR segment — should fail require_segment and
  # require_cardinality for OBR.
  @oru_without_obr_wire "MSH|^~\\&|LAB|HOSP|HIS|HOSP|20260409140000||ORU^R01^ORU_R01|MSG100|P|2.5.1\r" <>
                          "PID|1||12345^^^MRN||Smith^John||19800315|M\r"

  # Valid ORU_R01 with OBR + OBX populated to satisfy every rule.
  @oru_full_wire "MSH|^~\\&|LAB|HOSP|HIS|HOSP|20260409140000||ORU^R01^ORU_R01|MSG101|P|2.5.1\r" <>
                   "PID|1||12345^^^MRN||Smith^John||19800315|M\r" <>
                   "OBR|1||ORD001|CBC^Complete Blood Count^LN|||20260409\r" <>
                   "OBX|1|NM|WBC^White Blood Cell^LN||7.5|10*3/uL|4.0-11.0|N|||F\r"

  defp parse!(wire) do
    {:ok, msg} = HL7v2.parse(wire, mode: :typed)
    msg
  end

  # --- hospital_adt_a01/0 -----------------------------------------------

  describe "hospital_adt_a01/0" do
    test "returns a Profile struct with expected metadata" do
      profile = Examples.hospital_adt_a01()

      assert %Profile{} = profile
      assert profile.name == "Hospital_ADT_A01"
      assert profile.message_type == {"ADT", "A01"}
      assert profile.version == "2.5.1"
      assert profile.description =~ "ADT_A01"
    end

    test "encodes the documented rule set" do
      profile = Examples.hospital_adt_a01()

      # require_segment("NK1")
      assert Profile.required_segments?(profile) == ["NK1"]

      # require_field("PID", 18) and require_field("PV1", 3)
      assert profile.required_fields[{"PID", 18}] == :required
      assert profile.required_fields[{"PV1", 3}] == :required

      # require_cardinality("DG1", min: 1, max: :unbounded)
      assert profile.cardinality_constraints["DG1"] == {1, :unbounded}

      # add_value_constraint on PV1-2
      assert Map.has_key?(profile.value_constraints, {"PV1", 2})
    end

    test "applies only to ADT_A01 messages" do
      profile = Examples.hospital_adt_a01()

      assert Profile.applies_to?(profile, {"ADT", "A01"}) == true
      assert Profile.applies_to?(profile, {"ORU", "R01"}) == false
    end

    test "minimal ADT_A01 triggers NK1, DG1, and PID-18 errors" do
      msg = parse!(@minimal_adt_wire)
      errors = ProfileRules.check(msg, Examples.hospital_adt_a01())

      rules = errors |> Enum.map(& &1.rule) |> Enum.sort() |> Enum.uniq()

      assert :require_segment in rules
      assert :require_cardinality in rules
      assert :require_field in rules

      nk1_error =
        Enum.find(errors, &(&1.rule == :require_segment and &1.location == "NK1"))

      assert nk1_error != nil
      assert nk1_error.profile == "Hospital_ADT_A01"

      dg1_error =
        Enum.find(errors, &(&1.rule == :require_cardinality and &1.location == "DG1"))

      assert dg1_error != nil
      assert dg1_error.message =~ "at least 1"

      pid_18_error =
        Enum.find(
          errors,
          &(&1.rule == :require_field and &1.location == "PID" and
              &1.field == :patient_account_number)
        )

      assert pid_18_error != nil
      assert pid_18_error.message =~ "PID-18"
    end

    test "full ADT_A01 with all required content passes the hospital profile" do
      msg = parse!(@full_adt_wire)

      assert ProfileRules.check(msg, Examples.hospital_adt_a01()) == []
    end

    test "invalid patient_class triggers value_constraint error" do
      msg = parse!(@bad_patient_class_wire)
      errors = ProfileRules.check(msg, Examples.hospital_adt_a01())

      assert [%{rule: :value_constraint, location: "PV1"} = error] = errors
      assert error.field == :patient_class
      assert error.profile == "Hospital_ADT_A01"
    end

    test "integrates with HL7v2.validate/2" do
      msg = parse!(@full_adt_wire)

      case HL7v2.validate(msg, profile: Examples.hospital_adt_a01()) do
        :ok ->
          :ok

        {:ok, warnings} ->
          refute Enum.any?(warnings, &(Map.get(&1, :profile) == "Hospital_ADT_A01"))

        {:error, errors} ->
          refute Enum.any?(errors, &(Map.get(&1, :profile) == "Hospital_ADT_A01"))
      end
    end
  end

  # --- ihe_lab_oru_r01/0 ------------------------------------------------

  describe "ihe_lab_oru_r01/0" do
    test "returns a Profile struct with expected metadata" do
      profile = Examples.ihe_lab_oru_r01()

      assert %Profile{} = profile
      assert profile.name == "IHE_LAB_ORU_R01"
      assert profile.message_type == {"ORU", "R01"}
      assert profile.version == "2.5.1"
      assert profile.description =~ "lab results"
    end

    test "encodes the documented rule set" do
      profile = Examples.ihe_lab_oru_r01()

      assert Profile.required_segments?(profile) == ["OBR"]
      assert profile.cardinality_constraints["OBX"] == {1, :unbounded}

      assert profile.required_fields[{"OBR", 4}] == :required
      assert profile.required_fields[{"OBX", 3}] == :required
      assert profile.required_fields[{"OBX", 11}] == :required

      assert Map.has_key?(profile.value_constraints, {"OBX", 11})
    end

    test "applies only to ORU_R01 messages" do
      profile = Examples.ihe_lab_oru_r01()

      assert Profile.applies_to?(profile, {"ORU", "R01"}) == true
      assert Profile.applies_to?(profile, {"ADT", "A01"}) == false
    end

    test "ORU without OBR triggers missing-segment and cardinality errors" do
      msg = parse!(@oru_without_obr_wire)
      errors = ProfileRules.check(msg, Examples.ihe_lab_oru_r01())

      rules = errors |> Enum.map(& &1.rule) |> Enum.uniq()

      assert :require_segment in rules
      assert :require_cardinality in rules

      obr_missing =
        Enum.find(errors, &(&1.rule == :require_segment and &1.location == "OBR"))

      assert obr_missing != nil
      assert obr_missing.profile == "IHE_LAB_ORU_R01"

      obx_cardinality =
        Enum.find(errors, &(&1.rule == :require_cardinality and &1.location == "OBX"))

      assert obx_cardinality != nil
      assert obx_cardinality.message =~ "at least 1"
    end

    test "full ORU_R01 with OBR + OBX passes the IHE lab profile" do
      msg = parse!(@oru_full_wire)

      assert ProfileRules.check(msg, Examples.ihe_lab_oru_r01()) == []
    end

    test "integrates with HL7v2.validate/2" do
      msg = parse!(@oru_full_wire)

      case HL7v2.validate(msg, profile: Examples.ihe_lab_oru_r01()) do
        :ok ->
          :ok

        {:ok, warnings} ->
          refute Enum.any?(warnings, &(Map.get(&1, :profile) == "IHE_LAB_ORU_R01"))

        {:error, errors} ->
          refute Enum.any?(errors, &(Map.get(&1, :profile) == "IHE_LAB_ORU_R01"))
      end
    end
  end
end
