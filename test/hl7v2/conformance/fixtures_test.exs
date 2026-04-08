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
  end
end
