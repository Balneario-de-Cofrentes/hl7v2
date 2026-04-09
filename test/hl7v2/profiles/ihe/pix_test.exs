defmodule HL7v2.Profiles.IHE.PIXTest do
  use ExUnit.Case, async: true

  alias HL7v2.Profile
  alias HL7v2.Profiles.IHE.PIX
  alias HL7v2.Validation.ProfileRules

  # --- Fixtures ---------------------------------------------------------

  # Valid ITI-8 A01 feed in v2.3.1 with assigning authority.
  @valid_iti_8_a01 "MSH|^~\\&|HIS|HOSP|PIX|MGR|20260409120000||ADT^A01|MSG001|P|2.3.1\r" <>
                     "EVN||20260409120000\r" <>
                     "PID|1||12345^^^HOSP_MRN&1.2.3&ISO^MR||Smith^John\r" <>
                     "PV1|1|I\r"

  # Same wire but v2.5 — should NOT match the v2.3.1 profile.
  @v25_a01 "MSH|^~\\&|HIS|HOSP|PIX|MGR|20260409120000||ADT^A01|MSG002|P|2.5\r" <>
             "EVN||20260409120000\r" <>
             "PID|1||12345^^^HOSP_MRN&1.2.3&ISO^MR||Smith^John\r" <>
             "PV1|1|I\r"

  # ITI-8 A40 merge with MRG populated.
  @valid_iti_8_a40 "MSH|^~\\&|HIS|HOSP|PIX|MGR|20260409120000||ADT^A40|MSG003|P|2.3.1\r" <>
                     "EVN||20260409120000\r" <>
                     "PID|1||99999^^^HOSP_MRN&1.2.3&ISO^MR||Smith^John\r" <>
                     "MRG|12345^^^HOSP_MRN&1.2.3&ISO^MR\r"

  # ITI-8 A40 missing MRG-1 — should fire :require_field for MRG.
  @iti_8_a40_no_mrg1 "MSH|^~\\&|HIS|HOSP|PIX|MGR|20260409120000||ADT^A40|MSG004|P|2.3.1\r" <>
                       "EVN||20260409120000\r" <>
                       "PID|1||99999^^^HOSP_MRN&1.2.3&ISO^MR||Smith^John\r" <>
                       "MRG||\r"

  # Valid ITI-9 QBP^Q23 query (v2.5). QPD carries "IHE PIX Query" in the
  # first component of QPD-1, a query tag, and a patient identifier in
  # QPD-3. RCP-1 = "I".
  @valid_iti_9_query "MSH|^~\\&|REQ|HOSP|PIX|MGR|20260409120000||QBP^Q23^QBP_Q21|MSG005|P|2.5\r" <>
                       "QPD|IHE PIX Query|QRY001|12345^^^HOSP_MRN&1.2.3&ISO^MR\r" <>
                       "RCP|I\r"

  # ITI-9 query with the wrong QPD-1 name — should fire :value_constraint.
  @iti_9_query_wrong_name "MSH|^~\\&|REQ|HOSP|PIX|MGR|20260409120000||QBP^Q23^QBP_Q21|MSG006|P|2.5\r" <>
                            "QPD|Wrong Query Name|QRY002|12345^^^HOSP_MRN&1.2.3&ISO^MR\r" <>
                            "RCP|I\r"

  # ITI-9 query with RCP-1 = "D" (Deferred) — should fire :value_constraint.
  @iti_9_query_deferred "MSH|^~\\&|REQ|HOSP|PIX|MGR|20260409120000||QBP^Q23^QBP_Q21|MSG007|P|2.5\r" <>
                          "QPD|IHE PIX Query|QRY003|12345^^^HOSP_MRN&1.2.3&ISO^MR\r" <>
                          "RCP|D\r"

  # Valid ITI-9 response RSP^K23.
  @valid_iti_9_response "MSH|^~\\&|PIX|MGR|REQ|HOSP|20260409120000||RSP^K23^RSP_K23|MSG008|P|2.5\r" <>
                          "MSA|AA|MSG005\r" <>
                          "QAK|QRY001|OK\r" <>
                          "QPD|IHE PIX Query|QRY001|12345^^^HOSP_MRN&1.2.3&ISO^MR\r"

  # Valid ITI-10 update — PV1-2 = "N", PID-3 with assigning authority.
  @valid_iti_10 "MSH|^~\\&|PIX|MGR|HIS|HOSP|20260409120000||ADT^A31^ADT_A05|MSG009|P|2.5\r" <>
                  "EVN||20260409120000\r" <>
                  "PID|1||12345^^^HOSP_MRN&1.2.3&ISO^MR||Smith^John\r" <>
                  "PV1|1|N\r"

  # ITI-10 with PV1-2 = "I" — should fire :value_constraint.
  @iti_10_wrong_class "MSH|^~\\&|PIX|MGR|HIS|HOSP|20260409120000||ADT^A31^ADT_A05|MSG010|P|2.5\r" <>
                        "EVN||20260409120000\r" <>
                        "PID|1||12345^^^HOSP_MRN&1.2.3&ISO^MR||Smith^John\r" <>
                        "PV1|1|I\r"

  defp parse!(wire) do
    {:ok, msg} = HL7v2.parse(wire, mode: :typed)
    msg
  end

  # --- ITI-8 Feed A01 (v2.3.1) ------------------------------------------

  describe "iti_8_feed_a01/0" do
    test "metadata identifies v2.3.1 profile" do
      profile = PIX.iti_8_feed_a01()
      assert profile.name == "IHE_ITI-8_ADT_A01"
      assert profile.message_type == {"ADT", "A01"}
      assert profile.version == "2.3.1"
    end

    test "required segments include MSH, EVN, PID, PV1" do
      profile = PIX.iti_8_feed_a01()
      required = Profile.required_segments?(profile)

      assert "MSH" in required
      assert "EVN" in required
      assert "PID" in required
      assert "PV1" in required
    end

    test "requires PID-3 and PID-5" do
      profile = PIX.iti_8_feed_a01()
      assert profile.required_fields[{"PID", 3}] == :required
      assert profile.required_fields[{"PID", 5}] == :required
    end

    test "valid v2.3.1 ITI-8 A01 passes" do
      msg = parse!(@valid_iti_8_a01)
      assert ProfileRules.check(msg, PIX.iti_8_feed_a01()) == []
    end

    test "v2.5 ADT^A01 is silently skipped by the v2.3.1 ITI-8 profile" do
      msg = parse!(@v25_a01)
      # Profile is for v2.3.1; v2.5 message should not match → no errors.
      assert ProfileRules.check(msg, PIX.iti_8_feed_a01()) == []
    end
  end

  describe "iti_8_feed_a04/0" do
    test "metadata" do
      profile = PIX.iti_8_feed_a04()
      assert profile.name == "IHE_ITI-8_ADT_A04"
      assert profile.version == "2.3.1"
    end
  end

  describe "iti_8_feed_a08/0" do
    test "metadata" do
      profile = PIX.iti_8_feed_a08()
      assert profile.name == "IHE_ITI-8_ADT_A08"
      assert profile.version == "2.3.1"
    end
  end

  # --- ITI-8 Feed A40 (merge) -------------------------------------------

  describe "iti_8_feed_a40/0" do
    test "requires MRG segment" do
      profile = PIX.iti_8_feed_a40()
      assert "MRG" in Profile.required_segments?(profile)
      assert profile.required_fields[{"MRG", 1}] == :required
    end

    test "valid merge passes" do
      msg = parse!(@valid_iti_8_a40)
      assert ProfileRules.check(msg, PIX.iti_8_feed_a40()) == []
    end

    test "missing MRG-1 fires :require_field on MRG" do
      msg = parse!(@iti_8_a40_no_mrg1)
      errors = ProfileRules.check(msg, PIX.iti_8_feed_a40())

      assert Enum.any?(errors, fn e ->
               e.rule == :require_field and e.location == "MRG" and
                 e.profile == "IHE_ITI-8_ADT_A40"
             end)
    end
  end

  # --- ITI-9 PIX Query (QBP^Q23, v2.5) ----------------------------------

  describe "iti_9_query/0" do
    test "metadata identifies v2.5 profile" do
      profile = PIX.iti_9_query()
      assert profile.message_type == {"QBP", "Q23"}
      assert profile.version == "2.5"
    end

    test "requires MSH, QPD, RCP and their key fields" do
      profile = PIX.iti_9_query()
      required = Profile.required_segments?(profile)

      assert "QPD" in required
      assert "RCP" in required
      assert profile.required_fields[{"QPD", 1}] == :required
      assert profile.required_fields[{"QPD", 2}] == :required
      assert profile.required_fields[{"QPD", 3}] == :required
      assert profile.required_fields[{"RCP", 1}] == :required
    end

    test "valid query passes" do
      msg = parse!(@valid_iti_9_query)
      assert ProfileRules.check(msg, PIX.iti_9_query()) == []
    end

    test "wrong QPD-1 name fires :value_constraint" do
      msg = parse!(@iti_9_query_wrong_name)
      errors = ProfileRules.check(msg, PIX.iti_9_query())

      assert Enum.any?(errors, fn e ->
               e.rule == :value_constraint and e.location == "QPD" and
                 e.profile == "IHE_ITI-9_PIX_Query"
             end)
    end

    test "RCP-1 = 'D' (not Immediate) fires :value_constraint" do
      msg = parse!(@iti_9_query_deferred)
      errors = ProfileRules.check(msg, PIX.iti_9_query())

      assert Enum.any?(errors, fn e ->
               e.rule == :value_constraint and e.location == "RCP"
             end)
    end
  end

  # --- ITI-9 PIX Response (RSP^K23, v2.5) -------------------------------

  describe "iti_9_response/0" do
    test "metadata" do
      profile = PIX.iti_9_response()
      assert profile.message_type == {"RSP", "K23"}
      assert profile.version == "2.5"
    end

    test "requires MSH, MSA, QAK, QPD" do
      profile = PIX.iti_9_response()
      required = Profile.required_segments?(profile)

      assert "MSA" in required
      assert "QAK" in required
      assert "QPD" in required
    end

    test "valid response passes" do
      msg = parse!(@valid_iti_9_response)
      assert ProfileRules.check(msg, PIX.iti_9_response()) == []
    end
  end

  # --- ITI-10 Update Notification (ADT^A31, v2.5) -----------------------

  describe "iti_10_update/0" do
    test "metadata" do
      profile = PIX.iti_10_update()
      assert profile.message_type == {"ADT", "A31"}
      assert profile.version == "2.5"
    end

    test "pins PV1-2 to 'N'" do
      profile = PIX.iti_10_update()
      assert Map.has_key?(profile.value_constraints, {"PV1", 2})
    end

    test "valid update passes" do
      msg = parse!(@valid_iti_10)
      assert ProfileRules.check(msg, PIX.iti_10_update()) == []
    end

    test "PV1-2 = 'I' (not N) fires :value_constraint" do
      msg = parse!(@iti_10_wrong_class)
      errors = ProfileRules.check(msg, PIX.iti_10_update())

      assert Enum.any?(errors, fn e ->
               e.rule == :value_constraint and e.location == "PV1" and
                 e.profile == "IHE_ITI-10_PIX_Update"
             end)
    end
  end

  # --- catalog ----------------------------------------------------------

  describe "all/0" do
    test "returns 7 PIX profiles" do
      catalog = PIX.all()

      assert map_size(catalog) == 7
      assert Map.has_key?(catalog, "ITI-8.A01")
      assert Map.has_key?(catalog, "ITI-8.A04")
      assert Map.has_key?(catalog, "ITI-8.A08")
      assert Map.has_key?(catalog, "ITI-8.A40")
      assert Map.has_key?(catalog, "ITI-9.Query")
      assert Map.has_key?(catalog, "ITI-9.Response")
      assert Map.has_key?(catalog, "ITI-10")
    end

    test "ITI-8 profiles are all v2.3.1, ITI-9/10 are v2.5" do
      catalog = PIX.all()

      for {code, profile} <- catalog do
        expected =
          cond do
            String.starts_with?(code, "ITI-8") -> "2.3.1"
            true -> "2.5"
          end

        assert profile.version == expected, "#{code} should be #{expected}"
      end
    end
  end
end
