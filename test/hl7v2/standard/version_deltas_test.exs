defmodule HL7v2.Standard.VersionDeltasTest do
  use ExUnit.Case, async: true

  alias HL7v2.Standard.VersionDeltas

  doctest HL7v2.Standard.VersionDeltas

  describe "exempt?/3" do
    test "returns false for the baseline v2.5.1 version" do
      refute VersionDeltas.exempt?("PID", 13, "2.5.1")
      refute VersionDeltas.exempt?("PID", 14, "2.5.1")
      refute VersionDeltas.exempt?("OBR", 10, "2.5.1")
      refute VersionDeltas.exempt?("OBR", 16, "2.5.1")
      refute VersionDeltas.exempt?("ORC", 10, "2.5.1")
      refute VersionDeltas.exempt?("ORC", 12, "2.5.1")
    end

    test "returns false when the version is nil" do
      refute VersionDeltas.exempt?("PID", 13, nil)
      refute VersionDeltas.exempt?("OBR", 10, nil)
    end

    test "returns false for pre-v2.7 versions" do
      refute VersionDeltas.exempt?("PID", 13, "2.3")
      refute VersionDeltas.exempt?("PID", 13, "2.4")
      refute VersionDeltas.exempt?("PID", 13, "2.5")
      refute VersionDeltas.exempt?("PID", 13, "2.6")
    end

    test "returns true for PID-13 at v2.7" do
      assert VersionDeltas.exempt?("PID", 13, "2.7")
    end

    test "returns true for PID-13 at v2.8" do
      assert VersionDeltas.exempt?("PID", 13, "2.8")
    end

    test "returns true for PID-14 at v2.7" do
      assert VersionDeltas.exempt?("PID", 14, "2.7")
    end

    test "returns true for OBR-10, OBR-16, ORC-10, ORC-12 at v2.7" do
      assert VersionDeltas.exempt?("OBR", 10, "2.7")
      assert VersionDeltas.exempt?("OBR", 16, "2.7")
      assert VersionDeltas.exempt?("ORC", 10, "2.7")
      assert VersionDeltas.exempt?("ORC", 12, "2.7")
    end

    test "accepts canonical versions produced by Version.normalize/1" do
      assert VersionDeltas.exempt?("PID", 13, HL7v2.Standard.Version.normalize("v2.7"))
      assert VersionDeltas.exempt?("PID", 13, HL7v2.Standard.Version.normalize("2.7.1"))
    end

    test "returns false for a non-deprecated field on an otherwise-affected segment at v2.7" do
      # PID-5 (patient_name) is not deprecated — must still be enforced at v2.7
      refute VersionDeltas.exempt?("PID", 5, "2.7")
      refute VersionDeltas.exempt?("PID", 3, "2.7")
      # OBR-4 (universal_service_identifier) is required and not deprecated
      refute VersionDeltas.exempt?("OBR", 4, "2.7")
      # ORC-1 (order_control) is required and not deprecated
      refute VersionDeltas.exempt?("ORC", 1, "2.7")
    end

    test "returns false for an unknown segment at v2.7" do
      refute VersionDeltas.exempt?("ZZZ", 13, "2.7")
      refute VersionDeltas.exempt?("MSH", 13, "2.7")
    end

    test "returns false for garbage version strings" do
      refute VersionDeltas.exempt?("PID", 13, "garbage")
      refute VersionDeltas.exempt?("PID", 13, "")
    end

    test "returns false for non-binary version arguments" do
      refute VersionDeltas.exempt?("PID", 13, :not_a_string)
      refute VersionDeltas.exempt?("PID", 13, 27)
    end
  end

  describe "v27_deprecations/0" do
    test "returns the full list of tracked v2.7 deprecations" do
      expected = [
        {"PID", 13},
        {"PID", 14},
        {"OBR", 10},
        {"OBR", 16},
        {"ORC", 10},
        {"ORC", 12}
      ]

      assert VersionDeltas.v27_deprecations() == expected
    end

    test "every returned entry is exempt at v2.7 and not at v2.5.1" do
      for {segment_id, seq} <- VersionDeltas.v27_deprecations() do
        assert VersionDeltas.exempt?(segment_id, seq, "2.7"),
               "expected #{segment_id}-#{seq} exempt at v2.7"

        refute VersionDeltas.exempt?(segment_id, seq, "2.5.1"),
               "expected #{segment_id}-#{seq} NOT exempt at v2.5.1"
      end
    end
  end
end
