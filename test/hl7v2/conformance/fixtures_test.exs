defmodule HL7v2.Conformance.FixturesTest do
  use ExUnit.Case, async: true

  alias HL7v2.Conformance.Fixtures

  describe "coverage/0" do
    test "returns a map with files, canonical, total_official, and pct" do
      cov = Fixtures.coverage()

      assert is_integer(cov.files) and cov.files > 0
      assert is_integer(cov.canonical) and cov.canonical > 0
      assert cov.total_official == 186
      assert is_float(cov.pct)
    end

    test "canonical count never exceeds file count" do
      cov = Fixtures.coverage()
      assert cov.canonical <= cov.files
    end

    test "percentage matches canonical / total_official" do
      cov = Fixtures.coverage()
      expected = Float.round(cov.canonical / cov.total_official * 100, 1)
      assert cov.pct == expected
    end
  end

  describe "list_fixtures/0" do
    test "returns sorted .hl7 files" do
      files = Fixtures.list_fixtures()
      assert Enum.all?(files, &String.ends_with?(&1, ".hl7"))
      assert files == Enum.sort(files)
    end
  end

  describe "unique_canonical_structures/1" do
    test "returns a sorted deduplicated list" do
      canonical = Fixtures.unique_canonical_structures()
      assert canonical == Enum.sort(canonical)
      assert canonical == Enum.uniq(canonical)
      assert Enum.all?(canonical, &is_binary/1)
    end

    test "includes known structures (ADT_A01, ORU_R01)" do
      canonical = Fixtures.unique_canonical_structures()
      assert "ADT_A01" in canonical
      assert "ORU_R01" in canonical
    end

    test "ACK^A01^ACK_A01 fixture resolves to bare ACK structure, not ACK_A01" do
      # The unregistered ACK_A01 alias must fall back to the registered ACK
      # structure — mirroring the same fallback HL7v2.Validation uses.
      canonical = Fixtures.unique_canonical_structures()
      assert "ACK" in canonical
      refute "ACK_A01" in canonical
    end

    test "every entry is a registered structure in the MessageStructure registry" do
      canonical = Fixtures.unique_canonical_structures()

      for name <- canonical do
        assert HL7v2.Standard.MessageStructure.get(name) != nil,
               "canonical '#{name}' returned by Fixtures is not registered"
      end
    end
  end

  describe "check_freshness/0" do
    test "returns :ok when compile-time snapshot matches on-disk fixtures" do
      assert Fixtures.check_freshness() == :ok
    end
  end

  describe "families/0" do
    test "returns sorted family prefixes" do
      families = Fixtures.families()
      assert families == Enum.sort(families)
      assert Enum.all?(families, &is_binary/1)
    end

    test "includes ADT, ORU, MFN" do
      families = Fixtures.families()
      assert "ADT" in families
      assert "ORU" in families
      assert "MFN" in families
    end

    test "does NOT include ORI (not in current corpus)" do
      # Guards against hand-curated family lists drifting from actual corpus
      families = Fixtures.families()
      refute "ORI" in families
    end
  end
end
