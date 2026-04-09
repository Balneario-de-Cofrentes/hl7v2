defmodule HL7v2.Validation.ProfileRulesTest do
  use ExUnit.Case, async: true

  alias HL7v2.Profile
  alias HL7v2.Validation.ProfileRules

  # --- Fixtures ----------------------------------------------------------

  @adt_a01_wire "MSH|^~\\&|HIS|HOSP|PHAOS|VNA|20240115120000||ADT^A01^ADT_A01|MSG00001|P|2.5\r" <>
                  "EVN|A01|20240115120000\r" <>
                  "PID|1||12345^^^MRN~67890^^^SSN||Smith^John^Michael^^Dr||19800315|M\r" <>
                  "PV1|1|I|ICU^101^A^^^HOSP||||1234^Jones^Sarah^M^^Dr|5678^Williams^Robert\r" <>
                  "NK1|1|Smith^Jane|SPO\r" <>
                  "AL1|1|DA|^Penicillin|MO|Rash\r" <>
                  "DG1|1||J18.9^Pneumonia^ICD10|||A\r"

  setup do
    {:ok, msg} = HL7v2.parse(@adt_a01_wire, mode: :typed)
    {:ok, msg: msg}
  end

  # --- check/2: applicability -------------------------------------------

  describe "check/2 applicability" do
    test "empty profile returns no errors", %{msg: msg} do
      assert ProfileRules.check(msg, Profile.new("empty")) == []
    end

    test "profile that does not match message type returns no errors", %{msg: msg} do
      profile = Profile.new("ORU only", message_type: {"ORU", "R01"})
      profile = Profile.require_segment(profile, "ZZZ")

      assert ProfileRules.check(msg, profile) == []
    end

    test "wildcard profile (nil message_type) evaluates against message", %{msg: msg} do
      profile =
        Profile.new("wild")
        |> Profile.require_segment("ZZZ")

      errors = ProfileRules.check(msg, profile)

      assert length(errors) == 1
      assert hd(errors).rule == :require_segment
    end

    test "profile matching on {code, event} tuple evaluates", %{msg: msg} do
      profile =
        Profile.new("ADT_A01", message_type: {"ADT", "A01"})
        |> Profile.require_segment("ZZZ")

      errors = ProfileRules.check(msg, profile)
      assert length(errors) == 1
    end
  end

  # --- require_segment ---------------------------------------------------

  describe "require_segment" do
    test "missing segment produces error tagged :require_segment", %{msg: msg} do
      profile =
        Profile.new("p")
        |> Profile.require_segment("ROL")

      assert [error] = ProfileRules.check(msg, profile)
      assert error.rule == :require_segment
      assert error.profile == "p"
      assert error.level == :error
      assert error.location == "ROL"
      assert error.field == nil
      assert error.message =~ "requires segment ROL"
    end

    test "multiple missing segments produce multiple errors", %{msg: msg} do
      profile =
        Profile.new("p")
        |> Profile.require_segment("ROL")
        |> Profile.require_segment("GT1")

      errors = ProfileRules.check(msg, profile)
      assert length(errors) == 2
      assert Enum.all?(errors, &(&1.rule == :require_segment))
    end

    test "present segment produces no error", %{msg: msg} do
      profile =
        Profile.new("p")
        |> Profile.require_segment("PID")
        |> Profile.require_segment("PV1")
        |> Profile.require_segment("NK1")

      assert ProfileRules.check(msg, profile) == []
    end
  end

  # --- forbid_segment ----------------------------------------------------

  describe "forbid_segment" do
    test "present segment produces error tagged :forbid_segment", %{msg: msg} do
      profile =
        Profile.new("p")
        |> Profile.forbid_segment("NK1")

      assert [error] = ProfileRules.check(msg, profile)
      assert error.rule == :forbid_segment
      assert error.location == "NK1"
      assert error.message =~ "forbids segment NK1"
    end

    test "absent segment produces no error", %{msg: msg} do
      profile =
        Profile.new("p")
        |> Profile.forbid_segment("ROL")
        |> Profile.forbid_segment("GT1")

      assert ProfileRules.check(msg, profile) == []
    end
  end

  # --- require_field -----------------------------------------------------

  describe "require_field" do
    test "populated field produces no error", %{msg: msg} do
      # PID-5 (patient_name) is populated in the fixture
      profile =
        Profile.new("p")
        |> Profile.require_field("PID", 5)

      assert ProfileRules.check(msg, profile) == []
    end

    test "nil field produces error with :require_field rule", %{msg: msg} do
      # PID-18 (patient_account_number) is not populated in the fixture
      profile =
        Profile.new("p")
        |> Profile.require_field("PID", 18)

      assert [error] = ProfileRules.check(msg, profile)
      assert error.rule == :require_field
      assert error.location == "PID"
      assert error.field == :patient_account_number
      assert error.message =~ "PID-18"
      assert error.message =~ "populated"
    end

    test "missing segment produces :require_field error", %{msg: msg} do
      profile =
        Profile.new("p")
        |> Profile.require_field("ROL", 3)

      assert [error] = ProfileRules.check(msg, profile)
      assert error.rule == :require_field
      assert error.location == "ROL"
      assert error.field == nil
      assert error.message =~ "segment ROL is missing"
    end
  end

  # --- require_cardinality ----------------------------------------------

  describe "require_cardinality" do
    test "count within range produces no error", %{msg: msg} do
      profile =
        Profile.new("p")
        |> Profile.require_cardinality("PID", min: 1, max: 1)
        |> Profile.require_cardinality("NK1", min: 1, max: 5)

      assert ProfileRules.check(msg, profile) == []
    end

    test "count below minimum produces error", %{msg: msg} do
      profile =
        Profile.new("p")
        |> Profile.require_cardinality("NK1", min: 3, max: 10)

      assert [error] = ProfileRules.check(msg, profile)
      assert error.rule == :require_cardinality
      assert error.location == "NK1"
      assert error.message =~ "at least 3"
      assert error.message =~ "found 1"
    end

    test "count above maximum produces error", %{msg: msg} do
      profile =
        Profile.new("p")
        |> Profile.require_cardinality("PID", min: 0, max: 0)

      assert [error] = ProfileRules.check(msg, profile)
      assert error.rule == :require_cardinality
      assert error.location == "PID"
      assert error.message =~ "at most 0"
      assert error.message =~ "found 1"
    end

    test "missing segment with min: 1 produces error", %{msg: msg} do
      profile =
        Profile.new("p")
        |> Profile.require_cardinality("ROL", min: 1, max: 5)

      assert [error] = ProfileRules.check(msg, profile)
      assert error.rule == :require_cardinality
      assert error.message =~ "at least 1"
      assert error.message =~ "found 0"
    end

    test ":unbounded max imposes no upper limit", %{msg: msg} do
      profile =
        Profile.new("p")
        |> Profile.require_cardinality("NK1", min: 1, max: :unbounded)

      assert ProfileRules.check(msg, profile) == []
    end
  end

  # --- value_constraint --------------------------------------------------

  describe "add_value_constraint" do
    test "constraint returning true produces no error", %{msg: msg} do
      profile =
        Profile.new("p")
        |> Profile.add_value_constraint("PID", 1, fn _v -> true end)

      assert ProfileRules.check(msg, profile) == []
    end

    test "constraint returning false produces error", %{msg: msg} do
      profile =
        Profile.new("p")
        |> Profile.add_value_constraint("PID", 1, fn _v -> false end)

      assert [error] = ProfileRules.check(msg, profile)
      assert error.rule == :value_constraint
      assert error.location == "PID"
      assert error.field == :set_id
      assert error.message =~ "value constraint failed"
    end

    test "constraint returning {:error, reason} includes reason in message", %{msg: msg} do
      profile =
        Profile.new("p")
        |> Profile.add_value_constraint("PID", 1, fn _v -> {:error, "must be positive"} end)

      assert [error] = ProfileRules.check(msg, profile)
      assert error.rule == :value_constraint
      assert error.message =~ "must be positive"
    end

    test "constraint that raises is caught safely and produces error", %{msg: msg} do
      profile =
        Profile.new("p")
        |> Profile.add_value_constraint("PID", 1, fn _v -> raise "boom!" end)

      assert [error] = ProfileRules.check(msg, profile)
      assert error.rule == :value_constraint
      assert error.message =~ "boom!"
    end

    test "constraint is not invoked when segment is missing", %{msg: msg} do
      ref = make_ref()
      test_pid = self()

      profile =
        Profile.new("p")
        |> Profile.add_value_constraint("ROL", 3, fn _v ->
          send(test_pid, {:called, ref})
          false
        end)

      assert ProfileRules.check(msg, profile) == []
      refute_received {:called, ^ref}
    end
  end

  # --- custom_rule -------------------------------------------------------

  describe "add_rule" do
    test "rule returning [] produces no error", %{msg: msg} do
      profile =
        Profile.new("p")
        |> Profile.add_rule(:always_ok, fn _ -> [] end)

      assert ProfileRules.check(msg, profile) == []
    end

    test "rule returning error maps tags them with :rule and :profile", %{msg: msg} do
      profile =
        Profile.new("my_profile")
        |> Profile.add_rule(:my_check, fn _ ->
          [%{level: :error, location: "X", field: nil, message: "bad"}]
        end)

      assert [error] = ProfileRules.check(msg, profile)
      assert error.rule == :my_check
      assert error.profile == "my_profile"
      assert error.level == :error
      assert error.location == "X"
      assert error.message == "bad"
    end

    test "rule can override :rule and :profile on its own errors", %{msg: msg} do
      profile =
        Profile.new("outer")
        |> Profile.add_rule(:outer_rule, fn _ ->
          [
            %{
              level: :warning,
              location: "Y",
              field: nil,
              message: "pre-tagged",
              rule: :inner_rule,
              profile: "inner"
            }
          ]
        end)

      assert [error] = ProfileRules.check(msg, profile)
      assert error.rule == :inner_rule
      assert error.profile == "inner"
      assert error.level == :warning
    end

    test "rule that raises is caught safely and returns no errors", %{msg: msg} do
      profile =
        Profile.new("p")
        |> Profile.add_rule(:crash, fn _ -> raise "boom!" end)

      assert ProfileRules.check(msg, profile) == []
    end
  end

  # --- aggregate behaviour ----------------------------------------------

  describe "multiple rules" do
    test "all failing rules contribute errors", %{msg: msg} do
      profile =
        Profile.new("strict")
        |> Profile.require_segment("ROL")
        |> Profile.forbid_segment("NK1")
        |> Profile.require_field("PID", 18)
        |> Profile.require_cardinality("PID", min: 2, max: 5)
        |> Profile.add_value_constraint("PID", 1, fn _ -> false end)
        |> Profile.add_rule(:custom, fn _ ->
          [%{level: :error, location: "Z", field: nil, message: "custom failed"}]
        end)

      errors = ProfileRules.check(msg, profile)

      rules = errors |> Enum.map(& &1.rule) |> Enum.sort()

      assert :require_segment in rules
      assert :forbid_segment in rules
      assert :require_field in rules
      assert :require_cardinality in rules
      assert :value_constraint in rules
      assert :custom in rules
    end

    test "every error map has the required keys", %{msg: msg} do
      profile =
        Profile.new("p")
        |> Profile.require_segment("ROL")
        |> Profile.forbid_segment("NK1")
        |> Profile.require_field("PID", 18)
        |> Profile.require_cardinality("PID", min: 2, max: 5)
        |> Profile.add_value_constraint("PID", 1, fn _ -> false end)
        |> Profile.add_rule(:custom, fn _ ->
          [%{level: :error, location: "Z", field: nil, message: "custom failed"}]
        end)

      for error <- ProfileRules.check(msg, profile) do
        assert Map.has_key?(error, :level)
        assert Map.has_key?(error, :location)
        assert Map.has_key?(error, :field)
        assert Map.has_key?(error, :message)
        assert Map.has_key?(error, :rule)
        assert Map.has_key?(error, :profile)
        assert error.level in [:error, :warning]
        assert is_binary(error.location)
        assert is_binary(error.message)
        assert is_atom(error.rule)
        assert is_binary(error.profile)
      end
    end
  end
end
