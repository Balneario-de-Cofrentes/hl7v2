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

  # Release-surface pins: these assertions lock the headline numbers that
  # appear in README, CHANGELOG, and GitHub release notes. They do two things:
  #
  #   1. Guard against silent corpus shrinkage that would go unnoticed in
  #      CI (e.g. a fixture file gets deleted or a rename makes it invisible
  #      to the frozen @external_resource tracker).
  #   2. Force any intentional corpus change to also update the tests, which
  #      means the release numbers in docs won't drift from reality again.
  #
  # When adding fixtures, update @min_fixture_files and @min_canonical_structures
  # to the new minimums. The tests use >= rather than == so additions are
  # celebrated, but removals fail loudly.
  describe "release-surface (headline numbers)" do
    # Minimums tracked in docs/README. Update when expanding the corpus.
    @min_fixture_files 110
    @min_canonical_structures 101
    @min_pct 54.3

    test "fixture count is at or above the documented minimum" do
      cov = Fixtures.coverage()

      assert cov.files >= @min_fixture_files,
             "corpus shrank: expected >= #{@min_fixture_files} files, got #{cov.files}. " <>
               "Update the minimum in fixtures_test.exs if this was intentional."
    end

    test "unique canonical structures >= documented minimum" do
      cov = Fixtures.coverage()

      assert cov.canonical >= @min_canonical_structures,
             "canonical coverage shrank: expected >= #{@min_canonical_structures}, " <>
               "got #{cov.canonical}. Update the minimum if intentional."
    end

    test "percentage of 186 official >= documented minimum" do
      cov = Fixtures.coverage()

      assert cov.pct >= @min_pct,
             "corpus percentage shrank: expected >= #{@min_pct}%, got #{cov.pct}%"
    end

    test "list_fixtures and unique_canonical_structures sizes match coverage/0" do
      cov = Fixtures.coverage()
      assert length(Fixtures.list_fixtures()) == cov.files
      assert length(Fixtures.unique_canonical_structures()) == cov.canonical
    end

    # Exact pins — fail on BOTH shrinkage and expansion-without-doc-update.
    # When adding fixtures, update these constants AND the README/CHANGELOG
    # in the same commit.
    @exact_fixture_files 110
    @exact_canonical 101
    @exact_pct 54.3

    test "fixture count is exactly the published number" do
      cov = Fixtures.coverage()

      assert cov.files == @exact_fixture_files,
             "fixture count changed from published #{@exact_fixture_files} to #{cov.files}. " <>
               "Update @exact_fixture_files in fixtures_test.exs AND README/CHANGELOG."
    end

    test "unique canonical structures is exactly the published number" do
      cov = Fixtures.coverage()

      assert cov.canonical == @exact_canonical,
             "canonical count changed from published #{@exact_canonical} to #{cov.canonical}. " <>
               "Update @exact_canonical in fixtures_test.exs AND README/CHANGELOG."
    end

    test "percentage is exactly the published number" do
      cov = Fixtures.coverage()

      assert cov.pct == @exact_pct,
             "pct changed from published #{@exact_pct} to #{cov.pct}. " <>
               "Update @exact_pct in fixtures_test.exs AND README/CHANGELOG."
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

  describe "check_freshness/1" do
    setup do
      # Use a temp dir with injected fixture list for isolated stale-case tests
      tmp = System.tmp_dir!() |> Path.join("hl7v2_freshness_test_#{:rand.uniform(1_000_000)}")
      File.mkdir_p!(tmp)
      on_exit(fn -> File.rm_rf!(tmp) end)
      %{tmp: tmp}
    end

    test "returns :ok when compile-time snapshot matches live on-disk state" do
      assert Fixtures.check_freshness() == :ok
    end

    test "returns :ok when dir + frozen list match exactly", %{tmp: tmp} do
      File.write!(Path.join(tmp, "a.hl7"), "")
      File.write!(Path.join(tmp, "b.hl7"), "")

      assert Fixtures.check_freshness(dir: tmp, frozen: ["a.hl7", "b.hl7"]) == :ok
    end

    test "flags files that exist on disk but not in frozen list", %{tmp: tmp} do
      File.write!(Path.join(tmp, "a.hl7"), "")
      File.write!(Path.join(tmp, "new.hl7"), "")

      assert {:stale, on_disk_only: ["new.hl7"], frozen_only: []} =
               Fixtures.check_freshness(dir: tmp, frozen: ["a.hl7"])
    end

    test "flags files that exist in frozen list but not on disk", %{tmp: tmp} do
      File.write!(Path.join(tmp, "a.hl7"), "")

      assert {:stale, on_disk_only: [], frozen_only: ["removed.hl7"]} =
               Fixtures.check_freshness(dir: tmp, frozen: ["a.hl7", "removed.hl7"])
    end

    test "flags both additions and removals simultaneously", %{tmp: tmp} do
      File.write!(Path.join(tmp, "kept.hl7"), "")
      File.write!(Path.join(tmp, "added.hl7"), "")

      assert {:stale, on_disk_only: ["added.hl7"], frozen_only: ["gone.hl7"]} =
               Fixtures.check_freshness(dir: tmp, frozen: ["kept.hl7", "gone.hl7"])
    end

    test "ignores non-.hl7 files on disk", %{tmp: tmp} do
      File.write!(Path.join(tmp, "a.hl7"), "")
      File.write!(Path.join(tmp, "README.md"), "")
      File.write!(Path.join(tmp, "notes.txt"), "")

      assert Fixtures.check_freshness(dir: tmp, frozen: ["a.hl7"]) == :ok
    end

    test "returns :error for missing dir by default (strict regression guard)" do
      missing = System.tmp_dir!() |> Path.join("does_not_exist_#{:rand.uniform(1_000_000)}")
      refute File.exists?(missing)

      assert {:error, :fixture_dir_unavailable} =
               Fixtures.check_freshness(dir: missing, frozen: ["a.hl7"])
    end

    test "returns :ok for missing dir when allow_missing: true (opt-out)" do
      missing = System.tmp_dir!() |> Path.join("does_not_exist_#{:rand.uniform(1_000_000)}")
      refute File.exists?(missing)

      assert Fixtures.check_freshness(dir: missing, frozen: ["a.hl7"], allow_missing: true) ==
               :ok
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
