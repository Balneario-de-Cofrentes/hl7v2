defmodule HL7v2.Profiles.IHE.PDQTest do
  use ExUnit.Case, async: true

  alias HL7v2.Profile
  alias HL7v2.Profiles.IHE.PDQ
  alias HL7v2.Validation.ProfileRules

  # --- Fixtures ---------------------------------------------------------

  @valid_iti_21_query "MSH|^~\\&|REQ|HOSP|PDQ|SUP|20260409120000||QBP^Q22^QBP_Q21|MSG001|P|2.5\r" <>
                        "QPD|IHE PDQ Query|QRY001|@PID.5.1.1^SMITH\r" <>
                        "RCP|I\r"

  @iti_21_query_wrong_name "MSH|^~\\&|REQ|HOSP|PDQ|SUP|20260409120000||QBP^Q22^QBP_Q21|MSG002|P|2.5\r" <>
                             "QPD|Wrong Query|QRY002|@PID.5.1.1^SMITH\r" <>
                             "RCP|I\r"

  @iti_21_query_deferred "MSH|^~\\&|REQ|HOSP|PDQ|SUP|20260409120000||QBP^Q22^QBP_Q21|MSG003|P|2.5\r" <>
                           "QPD|IHE PDQ Query|QRY003|@PID.5.1.1^SMITH\r" <>
                           "RCP|D\r"

  @valid_iti_21_response "MSH|^~\\&|PDQ|SUP|REQ|HOSP|20260409120000||RSP^K22^RSP_K21|MSG004|P|2.5\r" <>
                           "MSA|AA|MSG001\r" <>
                           "QAK|QRY001|OK\r" <>
                           "QPD|IHE PDQ Query|QRY001|@PID.5.1.1^SMITH\r"

  @iti_21_response_bad_msa "MSH|^~\\&|PDQ|SUP|REQ|HOSP|20260409120000||RSP^K22^RSP_K21|MSG005|P|2.5\r" <>
                             "MSA|XX|MSG001\r" <>
                             "QAK|QRY001|OK\r" <>
                             "QPD|IHE PDQ Query|QRY001|@PID.5.1.1^SMITH\r"

  @valid_iti_22_query "MSH|^~\\&|REQ|HOSP|PDQ|SUP|20260409120000||QBP^ZV1^QBP_Q21|MSG006|P|2.5\r" <>
                        "QPD|IHE PDQ Query|QRY004|@PID.5.1.1^JONES|@PV1.2^I\r" <>
                        "RCP|I\r"

  @valid_iti_22_response "MSH|^~\\&|PDQ|SUP|REQ|HOSP|20260409120000||RSP^ZV2^RSP_ZV2|MSG007|P|2.5\r" <>
                           "MSA|AA|MSG006\r" <>
                           "QAK|QRY004|OK\r" <>
                           "QPD|IHE PDQ Query|QRY004|@PID.5.1.1^JONES\r"

  defp parse!(wire) do
    {:ok, msg} = HL7v2.parse(wire, mode: :typed)
    msg
  end

  # --- ITI-21 Query -----------------------------------------------------

  describe "iti_21_query/0" do
    test "metadata" do
      profile = PDQ.iti_21_query()

      assert profile.name == "IHE_ITI-21_PDQ_Query"
      assert profile.message_type == {"QBP", "Q22"}
      assert profile.version == "2.5"
    end

    test "requires MSH, QPD, RCP and key fields" do
      profile = PDQ.iti_21_query()
      required = Profile.required_segments?(profile)

      assert "MSH" in required
      assert "QPD" in required
      assert "RCP" in required
      assert profile.required_fields[{"QPD", 1}] == :required
      assert profile.required_fields[{"QPD", 2}] == :required
      assert profile.required_fields[{"QPD", 3}] == :required
      assert profile.required_fields[{"RCP", 1}] == :required
    end

    test "applies only to QBP^Q22" do
      profile = PDQ.iti_21_query()

      assert Profile.applies_to?(profile, {"QBP", "Q22"})
      refute Profile.applies_to?(profile, {"QBP", "ZV1"})
      refute Profile.applies_to?(profile, {"QBP", "Q23"})
    end

    test "valid query passes" do
      msg = parse!(@valid_iti_21_query)
      assert ProfileRules.check(msg, PDQ.iti_21_query()) == []
    end

    test "wrong QPD-1 name fires :value_constraint" do
      msg = parse!(@iti_21_query_wrong_name)
      errors = ProfileRules.check(msg, PDQ.iti_21_query())

      assert Enum.any?(errors, fn e ->
               e.rule == :require_value and e.location == "QPD" and
                 e.profile == "IHE_ITI-21_PDQ_Query"
             end)
    end

    test "RCP-1 = 'D' fires :value_constraint" do
      msg = parse!(@iti_21_query_deferred)
      errors = ProfileRules.check(msg, PDQ.iti_21_query())

      assert Enum.any?(errors, fn e ->
               e.rule == :require_value and e.location == "RCP"
             end)
    end
  end

  # --- ITI-21 Response --------------------------------------------------

  describe "iti_21_response/0" do
    test "metadata" do
      profile = PDQ.iti_21_response()

      assert profile.message_type == {"RSP", "K22"}
      assert profile.version == "2.5"
    end

    test "requires MSH, MSA, QAK, QPD" do
      profile = PDQ.iti_21_response()
      required = Profile.required_segments?(profile)

      assert "MSA" in required
      assert "QAK" in required
      assert "QPD" in required
    end

    test "valid response passes" do
      msg = parse!(@valid_iti_21_response)
      assert ProfileRules.check(msg, PDQ.iti_21_response()) == []
    end

    test "invalid MSA-1 fires :value_constraint" do
      msg = parse!(@iti_21_response_bad_msa)
      errors = ProfileRules.check(msg, PDQ.iti_21_response())

      assert Enum.any?(errors, fn e ->
               e.rule == :require_value and e.location == "MSA" and
                 e.profile == "IHE_ITI-21_PDQ_Response"
             end)
    end
  end

  # --- ITI-22 Query (Visit Query) ---------------------------------------

  describe "iti_22_query/0" do
    test "metadata" do
      profile = PDQ.iti_22_query()

      assert profile.name == "IHE_ITI-22_PDQ_Visit_Query"
      assert profile.message_type == {"QBP", "ZV1"}
      assert profile.version == "2.5"
    end

    test "applies only to QBP^ZV1" do
      profile = PDQ.iti_22_query()

      assert Profile.applies_to?(profile, {"QBP", "ZV1"})
      refute Profile.applies_to?(profile, {"QBP", "Q22"})
    end

    test "valid visit query passes" do
      msg = parse!(@valid_iti_22_query)
      assert ProfileRules.check(msg, PDQ.iti_22_query()) == []
    end
  end

  # --- ITI-22 Response (Visit Response) ---------------------------------

  describe "iti_22_response/0" do
    test "metadata" do
      profile = PDQ.iti_22_response()

      assert profile.name == "IHE_ITI-22_PDQ_Visit_Response"
      assert profile.message_type == {"RSP", "ZV2"}
    end

    test "valid response passes" do
      msg = parse!(@valid_iti_22_response)
      assert ProfileRules.check(msg, PDQ.iti_22_response()) == []
    end
  end

  # --- catalog ----------------------------------------------------------

  describe "all/0" do
    test "returns 4 PDQ profiles" do
      catalog = PDQ.all()

      assert map_size(catalog) == 4
      assert Map.has_key?(catalog, "ITI-21.Query")
      assert Map.has_key?(catalog, "ITI-21.Response")
      assert Map.has_key?(catalog, "ITI-22.Query")
      assert Map.has_key?(catalog, "ITI-22.Response")

      for {_code, profile} <- catalog do
        assert profile.version == "2.5"
      end
    end
  end
end
