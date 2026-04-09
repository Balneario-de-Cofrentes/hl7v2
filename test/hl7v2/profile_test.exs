defmodule HL7v2.ProfileTest do
  use ExUnit.Case, async: true
  doctest HL7v2.Profile

  alias HL7v2.Profile

  describe "new/2" do
    test "creates a profile with just a name" do
      profile = Profile.new("Basic")

      assert %Profile{} = profile
      assert profile.name == "Basic"
      assert profile.message_type == nil
      assert profile.version == nil
      assert profile.description == ""
      assert %MapSet{} = profile.required_segments
      assert MapSet.size(profile.required_segments) == 0
      assert %MapSet{} = profile.forbidden_segments
      assert MapSet.size(profile.forbidden_segments) == 0
      assert profile.required_fields == %{}
      assert profile.field_table_bindings == %{}
      assert profile.cardinality_constraints == %{}
      assert profile.value_constraints == %{}
      assert profile.custom_rules == []
    end

    test "stores message_type option" do
      profile = Profile.new("ADT profile", message_type: {"ADT", "A01"})

      assert profile.message_type == {"ADT", "A01"}
    end

    test "stores version option" do
      profile = Profile.new("Versioned", version: "2.5.1")

      assert profile.version == "2.5.1"
    end

    test "stores description option" do
      profile = Profile.new("Documented", description: "Our hospital's ADT profile")

      assert profile.description == "Our hospital's ADT profile"
    end

    test "stores all options together" do
      profile =
        Profile.new("Full",
          message_type: {"ORU", "R01"},
          version: "2.7",
          description: "Lab results profile"
        )

      assert profile.name == "Full"
      assert profile.message_type == {"ORU", "R01"}
      assert profile.version == "2.7"
      assert profile.description == "Lab results profile"
    end

    test "raises on non-binary name" do
      assert_raise FunctionClauseError, fn -> Profile.new(:not_a_binary) end
    end
  end

  describe "require_segment/2" do
    test "adds a single required segment" do
      profile =
        Profile.new("p")
        |> Profile.require_segment("ROL")

      assert MapSet.member?(profile.required_segments, "ROL")
      assert MapSet.size(profile.required_segments) == 1
    end

    test "adds multiple distinct required segments" do
      profile =
        Profile.new("p")
        |> Profile.require_segment("ROL")
        |> Profile.require_segment("GT1")
        |> Profile.require_segment("IN1")

      assert MapSet.size(profile.required_segments) == 3
      assert MapSet.member?(profile.required_segments, "ROL")
      assert MapSet.member?(profile.required_segments, "GT1")
      assert MapSet.member?(profile.required_segments, "IN1")
    end

    test "deduplicates repeated segment entries" do
      profile =
        Profile.new("p")
        |> Profile.require_segment("ROL")
        |> Profile.require_segment("ROL")
        |> Profile.require_segment("ROL")

      assert MapSet.size(profile.required_segments) == 1
      assert MapSet.member?(profile.required_segments, "ROL")
    end
  end

  describe "forbid_segment/2" do
    test "adds a single forbidden segment" do
      profile =
        Profile.new("p")
        |> Profile.forbid_segment("Z01")

      assert MapSet.member?(profile.forbidden_segments, "Z01")
      assert MapSet.size(profile.forbidden_segments) == 1
    end

    test "adds multiple forbidden segments" do
      profile =
        Profile.new("p")
        |> Profile.forbid_segment("Z01")
        |> Profile.forbid_segment("ZPD")

      assert MapSet.size(profile.forbidden_segments) == 2
      assert MapSet.member?(profile.forbidden_segments, "Z01")
      assert MapSet.member?(profile.forbidden_segments, "ZPD")
    end

    test "does not cross-pollute required_segments" do
      profile =
        Profile.new("p")
        |> Profile.forbid_segment("Z01")

      assert MapSet.size(profile.required_segments) == 0
    end
  end

  describe "require_field/3" do
    test "adds a single required field" do
      profile =
        Profile.new("p")
        |> Profile.require_field("PID", 18)

      assert profile.required_fields == %{{"PID", 18} => :required}
    end

    test "adds multiple required fields in the same segment" do
      profile =
        Profile.new("p")
        |> Profile.require_field("PID", 3)
        |> Profile.require_field("PID", 5)
        |> Profile.require_field("PID", 18)

      assert map_size(profile.required_fields) == 3
      assert profile.required_fields[{"PID", 3}] == :required
      assert profile.required_fields[{"PID", 5}] == :required
      assert profile.required_fields[{"PID", 18}] == :required
    end

    test "adds required fields across multiple segments" do
      profile =
        Profile.new("p")
        |> Profile.require_field("PID", 5)
        |> Profile.require_field("PV1", 3)
        |> Profile.require_field("MSH", 10)

      assert map_size(profile.required_fields) == 3
      assert profile.required_fields[{"PID", 5}] == :required
      assert profile.required_fields[{"PV1", 3}] == :required
      assert profile.required_fields[{"MSH", 10}] == :required
    end

    test "rejects non-positive field sequence" do
      assert_raise FunctionClauseError, fn ->
        Profile.require_field(Profile.new("p"), "PID", 0)
      end
    end

    test "rejects negative field sequence" do
      assert_raise FunctionClauseError, fn ->
        Profile.require_field(Profile.new("p"), "PID", -1)
      end
    end
  end

  describe "bind_table/4" do
    test "adds a single table binding" do
      profile =
        Profile.new("p")
        |> Profile.bind_table("PV1", 14, "0069")

      assert profile.field_table_bindings == %{{"PV1", 14} => "0069"}
    end

    test "overrides an existing binding with the latest call" do
      profile =
        Profile.new("p")
        |> Profile.bind_table("PV1", 14, "0069")
        |> Profile.bind_table("PV1", 14, "9999")

      assert profile.field_table_bindings == %{{"PV1", 14} => "9999"}
    end

    test "accepts atom table IDs" do
      profile =
        Profile.new("p")
        |> Profile.bind_table("PV1", 14, :custom_table)

      assert profile.field_table_bindings == %{{"PV1", 14} => :custom_table}
    end

    test "keeps multiple independent bindings" do
      profile =
        Profile.new("p")
        |> Profile.bind_table("PV1", 14, "0069")
        |> Profile.bind_table("PID", 8, "0001")
        |> Profile.bind_table("PID", 10, "0005")

      assert map_size(profile.field_table_bindings) == 3
      assert profile.field_table_bindings[{"PV1", 14}] == "0069"
      assert profile.field_table_bindings[{"PID", 8}] == "0001"
      assert profile.field_table_bindings[{"PID", 10}] == "0005"
    end
  end

  describe "require_cardinality/3" do
    test "stores min/max cardinality" do
      profile =
        Profile.new("p")
        |> Profile.require_cardinality("OBX", min: 1, max: 10)

      assert profile.cardinality_constraints == %{"OBX" => {1, 10}}
    end

    test "supports unbounded max" do
      profile =
        Profile.new("p")
        |> Profile.require_cardinality("NTE", min: 0, max: :unbounded)

      assert profile.cardinality_constraints == %{"NTE" => {0, :unbounded}}
    end

    test "supports zero cardinality (effectively forbidden)" do
      profile =
        Profile.new("p")
        |> Profile.require_cardinality("Z01", min: 0, max: 0)

      assert profile.cardinality_constraints == %{"Z01" => {0, 0}}
    end

    test "latest constraint overrides earlier ones for the same segment" do
      profile =
        Profile.new("p")
        |> Profile.require_cardinality("OBX", min: 1, max: 10)
        |> Profile.require_cardinality("OBX", min: 2, max: 20)

      assert profile.cardinality_constraints == %{"OBX" => {2, 20}}
    end

    test "tracks multiple segments independently" do
      profile =
        Profile.new("p")
        |> Profile.require_cardinality("OBX", min: 1, max: 10)
        |> Profile.require_cardinality("NTE", min: 0, max: :unbounded)
        |> Profile.require_cardinality("DG1", min: 1, max: 5)

      assert map_size(profile.cardinality_constraints) == 3
      assert profile.cardinality_constraints["OBX"] == {1, 10}
      assert profile.cardinality_constraints["NTE"] == {0, :unbounded}
      assert profile.cardinality_constraints["DG1"] == {1, 5}
    end

    test "raises when :min is missing" do
      assert_raise KeyError, fn ->
        Profile.require_cardinality(Profile.new("p"), "OBX", max: 10)
      end
    end

    test "raises when :max is missing" do
      assert_raise KeyError, fn ->
        Profile.require_cardinality(Profile.new("p"), "OBX", min: 1)
      end
    end
  end

  describe "add_value_constraint/4" do
    test "stores a boolean-returning function" do
      fun = fn value -> value in ["M", "F", "O", "U"] end

      profile =
        Profile.new("p")
        |> Profile.add_value_constraint("PID", 8, fun)

      assert Map.has_key?(profile.value_constraints, {"PID", 8})
      stored = profile.value_constraints[{"PID", 8}]
      assert is_function(stored, 1)
      assert stored.("M") == true
      assert stored.("X") == false
    end

    test "stores an error-tuple-returning function" do
      fun = fn
        value when byte_size(value) > 0 -> true
        _ -> {:error, "must not be empty"}
      end

      profile =
        Profile.new("p")
        |> Profile.add_value_constraint("PID", 5, fun)

      stored = profile.value_constraints[{"PID", 5}]
      assert stored.("DOE^JOHN") == true
      assert stored.("") == {:error, "must not be empty"}
    end

    test "latest constraint overrides earlier ones for the same field" do
      first = fn _ -> true end
      second = fn _ -> false end

      profile =
        Profile.new("p")
        |> Profile.add_value_constraint("PID", 8, first)
        |> Profile.add_value_constraint("PID", 8, second)

      assert map_size(profile.value_constraints) == 1
      stored = profile.value_constraints[{"PID", 8}]
      assert stored.("anything") == false
    end

    test "stores multiple constraints on different fields" do
      profile =
        Profile.new("p")
        |> Profile.add_value_constraint("PID", 8, fn v -> v in ["M", "F"] end)
        |> Profile.add_value_constraint("PID", 15, fn v -> is_binary(v) end)
        |> Profile.add_value_constraint("PV1", 2, fn v -> v in ["I", "O", "E"] end)

      assert map_size(profile.value_constraints) == 3
      assert is_function(profile.value_constraints[{"PID", 8}], 1)
      assert is_function(profile.value_constraints[{"PID", 15}], 1)
      assert is_function(profile.value_constraints[{"PV1", 2}], 1)
    end

    test "rejects zero-arity functions" do
      assert_raise FunctionClauseError, fn ->
        Profile.add_value_constraint(Profile.new("p"), "PID", 8, fn -> true end)
      end
    end
  end

  describe "add_rule/3" do
    test "stores a custom rule under its name" do
      rule = fn _msg -> [] end

      profile =
        Profile.new("p")
        |> Profile.add_rule(:no_test_patients, rule)

      assert [{:no_test_patients, stored}] = profile.custom_rules
      assert is_function(stored, 1)
      assert stored.(:any_msg) == []
    end

    test "accumulates rules in reverse-insertion order (prepended)" do
      rule_a = fn _ -> [%{rule: :a}] end
      rule_b = fn _ -> [%{rule: :b}] end
      rule_c = fn _ -> [%{rule: :c}] end

      profile =
        Profile.new("p")
        |> Profile.add_rule(:rule_a, rule_a)
        |> Profile.add_rule(:rule_b, rule_b)
        |> Profile.add_rule(:rule_c, rule_c)

      assert length(profile.custom_rules) == 3
      names = Enum.map(profile.custom_rules, &elem(&1, 0))
      assert names == [:rule_c, :rule_b, :rule_a]
    end

    test "allows the same name registered twice (both retained)" do
      rule_v1 = fn _ -> [%{v: 1}] end
      rule_v2 = fn _ -> [%{v: 2}] end

      profile =
        Profile.new("p")
        |> Profile.add_rule(:dup, rule_v1)
        |> Profile.add_rule(:dup, rule_v2)

      assert length(profile.custom_rules) == 2
    end

    test "rejects non-atom rule names" do
      assert_raise FunctionClauseError, fn ->
        Profile.add_rule(Profile.new("p"), "not_an_atom", fn _ -> [] end)
      end
    end

    test "rejects non-arity-1 rule functions" do
      assert_raise FunctionClauseError, fn ->
        Profile.add_rule(Profile.new("p"), :bad, fn -> [] end)
      end
    end
  end

  describe "required_segments?/1 and forbidden_segments?/1" do
    test "required_segments?/1 returns sorted list" do
      profile =
        Profile.new("p")
        |> Profile.require_segment("ROL")
        |> Profile.require_segment("GT1")
        |> Profile.require_segment("IN1")
        |> Profile.require_segment("AL1")

      assert Profile.required_segments?(profile) == ["AL1", "GT1", "IN1", "ROL"]
    end

    test "required_segments?/1 returns empty list when none required" do
      assert Profile.required_segments?(Profile.new("p")) == []
    end

    test "forbidden_segments?/1 returns sorted list" do
      profile =
        Profile.new("p")
        |> Profile.forbid_segment("ZPD")
        |> Profile.forbid_segment("Z01")
        |> Profile.forbid_segment("ZFA")

      assert Profile.forbidden_segments?(profile) == ["Z01", "ZFA", "ZPD"]
    end

    test "forbidden_segments?/1 returns empty list when none forbidden" do
      assert Profile.forbidden_segments?(Profile.new("p")) == []
    end

    test "required and forbidden lists are independent" do
      profile =
        Profile.new("p")
        |> Profile.require_segment("ROL")
        |> Profile.forbid_segment("Z01")

      assert Profile.required_segments?(profile) == ["ROL"]
      assert Profile.forbidden_segments?(profile) == ["Z01"]
    end
  end

  describe "applies_to?/2" do
    test "wildcard profile applies to any message type" do
      profile = Profile.new("any")

      assert Profile.applies_to?(profile, {"ADT", "A01"}) == true
      assert Profile.applies_to?(profile, {"ORU", "R01"}) == true
      assert Profile.applies_to?(profile, nil) == true
    end

    test "specific profile applies to exact match" do
      profile = Profile.new("adt", message_type: {"ADT", "A01"})

      assert Profile.applies_to?(profile, {"ADT", "A01"}) == true
    end

    test "specific profile rejects different event" do
      profile = Profile.new("adt", message_type: {"ADT", "A01"})

      assert Profile.applies_to?(profile, {"ADT", "A04"}) == false
    end

    test "specific profile rejects different code" do
      profile = Profile.new("adt", message_type: {"ADT", "A01"})

      assert Profile.applies_to?(profile, {"ORU", "A01"}) == false
    end

    test "specific profile rejects nil message type" do
      profile = Profile.new("adt", message_type: {"ADT", "A01"})

      assert Profile.applies_to?(profile, nil) == false
    end
  end

  describe "pipe composition" do
    test "full builder chain yields a consistent profile" do
      profile =
        Profile.new("MyHospital_ADT_A01",
          message_type: {"ADT", "A01"},
          version: "2.5.1",
          description: "Our hospital's ADT_A01 profile"
        )
        |> Profile.require_segment("ROL")
        |> Profile.require_segment("GT1")
        |> Profile.forbid_segment("Z01")
        |> Profile.require_field("PID", 18)
        |> Profile.require_field("PV1", 3)
        |> Profile.bind_table("PV1", 14, "0069")
        |> Profile.bind_table("PID", 8, "0001")
        |> Profile.require_cardinality("OBX", min: 1, max: 10)
        |> Profile.require_cardinality("NTE", min: 0, max: :unbounded)
        |> Profile.add_value_constraint("PID", 8, fn v -> v in ["M", "F", "O", "U"] end)
        |> Profile.add_rule(:no_test_patients, fn _msg -> [] end)

      assert profile.name == "MyHospital_ADT_A01"
      assert profile.message_type == {"ADT", "A01"}
      assert profile.version == "2.5.1"
      assert profile.description == "Our hospital's ADT_A01 profile"

      assert Profile.required_segments?(profile) == ["GT1", "ROL"]
      assert Profile.forbidden_segments?(profile) == ["Z01"]

      assert map_size(profile.required_fields) == 2
      assert profile.required_fields[{"PID", 18}] == :required
      assert profile.required_fields[{"PV1", 3}] == :required

      assert map_size(profile.field_table_bindings) == 2
      assert profile.field_table_bindings[{"PV1", 14}] == "0069"
      assert profile.field_table_bindings[{"PID", 8}] == "0001"

      assert profile.cardinality_constraints["OBX"] == {1, 10}
      assert profile.cardinality_constraints["NTE"] == {0, :unbounded}

      assert Map.has_key?(profile.value_constraints, {"PID", 8})
      assert length(profile.custom_rules) == 1
      assert Profile.applies_to?(profile, {"ADT", "A01"}) == true
      assert Profile.applies_to?(profile, {"ORU", "R01"}) == false
    end

    test "builder calls in any order produce equivalent structure" do
      a =
        Profile.new("p")
        |> Profile.require_segment("ROL")
        |> Profile.require_field("PID", 5)
        |> Profile.bind_table("PV1", 14, "0069")

      b =
        Profile.new("p")
        |> Profile.bind_table("PV1", 14, "0069")
        |> Profile.require_field("PID", 5)
        |> Profile.require_segment("ROL")

      assert a.required_segments == b.required_segments
      assert a.required_fields == b.required_fields
      assert a.field_table_bindings == b.field_table_bindings
    end
  end

  describe "forbid_field/3" do
    alias HL7v2.Validation.ProfileRules

    test "stores forbidden fields in MapSet" do
      profile =
        Profile.new("p")
        |> Profile.forbid_field("MSH", 8)
        |> Profile.forbid_field("EVN", 1)

      assert %MapSet{} = profile.forbidden_fields
      assert MapSet.member?(profile.forbidden_fields, {"MSH", 8})
      assert MapSet.member?(profile.forbidden_fields, {"EVN", 1})
    end

    test "deduplicates repeat calls for the same field" do
      profile =
        Profile.new("p")
        |> Profile.forbid_field("MSH", 8)
        |> Profile.forbid_field("MSH", 8)

      assert MapSet.size(profile.forbidden_fields) == 1
    end

    test "raises on invalid arguments" do
      assert_raise FunctionClauseError, fn ->
        Profile.forbid_field(Profile.new("p"), "MSH", 0)
      end

      assert_raise FunctionClauseError, fn ->
        Profile.forbid_field(Profile.new("p"), :msh, 1)
      end
    end

    test "ProfileRules emits :forbid_field error when forbidden field is populated" do
      wire =
        "MSH|^~\\&|HIS|HOSP|PHAOS|VNA|20260409120000|SECURE|ADT^A01^ADT_A01|MSG001|P|2.5\r" <>
          "EVN|A01|20260409120000\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|I|ICU^101\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)

      profile =
        Profile.new("IHE_PAM_style", message_type: {"ADT", "A01"}, version: "2.5")
        |> Profile.forbid_field("MSH", 8)

      errors = ProfileRules.check(msg, profile)

      assert [
               %{
                 rule: :forbid_field,
                 location: "MSH",
                 field: :security,
                 profile: "IHE_PAM_style"
               } = err
             ] = errors

      assert err.message =~ "MSH-8"
    end

    test "ProfileRules does not fire when forbidden field is absent" do
      wire =
        "MSH|^~\\&|HIS|HOSP|PHAOS|VNA|20260409120000||ADT^A01^ADT_A01|MSG001|P|2.5\r" <>
          "EVN|A01|20260409120000\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|I|ICU^101\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)

      profile =
        Profile.new("IHE_PAM_style", message_type: {"ADT", "A01"}, version: "2.5")
        |> Profile.forbid_field("MSH", 8)

      assert ProfileRules.check(msg, profile) == []
    end

    test "ProfileRules is silent when the segment itself is missing" do
      wire =
        "MSH|^~\\&|HIS|HOSP|PHAOS|VNA|20260409120000||ADT^A01^ADT_A01|MSG001|P|2.5\r" <>
          "PID|1||12345^^^MRN||Smith^John\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)

      profile =
        Profile.new("p", message_type: {"ADT", "A01"}, version: "2.5")
        |> Profile.forbid_field("EVN", 1)

      # No EVN segment present; forbid_field is silent, use require_segment
      # if absence should also fire an error.
      refute Enum.any?(ProfileRules.check(msg, profile), &(&1.rule == :forbid_field))
    end
  end

  describe "version enforcement in ProfileRules.check/2" do
    alias HL7v2.Validation.ProfileRules

    @v25_wire "MSH|^~\\&|HIS|HOSP|PHAOS|VNA|20260409120000||ADT^A01^ADT_A01|MSG001|P|2.5\r" <>
                "EVN|A01|20260409120000\r" <>
                "PID|1||12345^^^MRN||Smith^John\r" <>
                "PV1|1|I|ICU^101\r"

    @v231_wire "MSH|^~\\&|HIS|HOSP|PHAOS|VNA|20260409120000||ADT^A01^ADT_A01|MSG001|P|2.3.1\r" <>
                 "EVN|A01|20260409120000\r" <>
                 "PID|1||12345^^^MRN||Smith^John\r" <>
                 "PV1|1|I|ICU^101\r"

    test "profile with matching version applies" do
      {:ok, msg} = HL7v2.parse(@v25_wire, mode: :typed)

      profile =
        Profile.new("v25_profile", message_type: {"ADT", "A01"}, version: "2.5")
        |> Profile.require_segment("OBR")

      # OBR is missing so check should fire the :require_segment rule,
      # which proves the profile applied.
      assert [%{rule: :require_segment, location: "OBR"}] = ProfileRules.check(msg, profile)
    end

    test "profile with mismatched version does not apply" do
      {:ok, msg} = HL7v2.parse(@v231_wire, mode: :typed)

      profile =
        Profile.new("v25_profile", message_type: {"ADT", "A01"}, version: "2.5")
        |> Profile.require_segment("OBR")

      # v2.5 profile should NOT match a v2.3.1 message — no errors fire.
      assert ProfileRules.check(msg, profile) == []
    end

    test "profile with nil version matches any message version" do
      {:ok, msg_v25} = HL7v2.parse(@v25_wire, mode: :typed)
      {:ok, msg_v231} = HL7v2.parse(@v231_wire, mode: :typed)

      profile =
        Profile.new("any_version", message_type: {"ADT", "A01"})
        |> Profile.require_segment("OBR")

      assert [%{rule: :require_segment}] = ProfileRules.check(msg_v25, profile)
      assert [%{rule: :require_segment}] = ProfileRules.check(msg_v231, profile)
    end
  end

  describe "custom_rule exception handling in ProfileRules.check/2" do
    alias HL7v2.Validation.ProfileRules

    test "a raising custom rule produces a :custom_rule_exception error" do
      wire =
        "MSH|^~\\&|HIS|HOSP|PHAOS|VNA|20260409120000||ADT^A01^ADT_A01|MSG001|P|2.5\r" <>
          "EVN|A01|20260409120000\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|I|ICU^101\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)

      profile =
        Profile.new("buggy_profile", message_type: {"ADT", "A01"})
        |> Profile.add_rule(:broken_rule, fn _msg ->
          raise "intentional failure"
        end)

      errors = ProfileRules.check(msg, profile)

      assert [%{rule: :custom_rule_exception, profile: "buggy_profile"} = err] = errors
      assert err.message =~ "broken_rule"
      assert err.message =~ "intentional failure"
    end

    test "a well-behaved custom rule still runs normally" do
      wire =
        "MSH|^~\\&|HIS|HOSP|PHAOS|VNA|20260409120000||ADT^A01^ADT_A01|MSG001|P|2.5\r" <>
          "EVN|A01|20260409120000\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|I|ICU^101\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)

      profile =
        Profile.new("good_profile", message_type: {"ADT", "A01"})
        |> Profile.add_rule(:good_rule, fn _msg ->
          [
            %{
              level: :error,
              location: "PID",
              field: :patient_name,
              message: "custom failure"
            }
          ]
        end)

      errors = ProfileRules.check(msg, profile)

      assert [%{rule: :good_rule, profile: "good_profile", location: "PID"}] = errors
    end
  end
end
