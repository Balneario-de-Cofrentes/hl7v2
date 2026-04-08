defmodule HL7v2.Conformance.PackagingTest do
  @moduledoc """
  Verifies the Hex package configuration ships the conformance fixture
  corpus so installed artifacts report the same coverage stats as the
  source tree. Catches mix.exs `package()[:files]` regressions before
  they reach Hex users.
  """
  use ExUnit.Case, async: true

  @fixture_dir Path.expand("../../../test/fixtures/conformance", __DIR__)

  describe "hex package includes conformance corpus" do
    test "package files: config includes test/fixtures/conformance" do
      config = Mix.Project.config()
      files = get_in(config, [:package, :files]) || []

      assert Enum.any?(files, &String.contains?(&1, "test/fixtures/conformance")),
             "mix.exs package()[:files] must include test/fixtures/conformance. " <>
               "Current files: #{inspect(files)}"
    end

    test "fixture directory exists and contains .hl7 files" do
      assert File.dir?(@fixture_dir),
             "fixture directory #{@fixture_dir} does not exist"

      {:ok, entries} = File.ls(@fixture_dir)
      hl7_files = Enum.filter(entries, &String.ends_with?(&1, ".hl7"))

      assert length(hl7_files) > 0,
             "fixture directory exists but contains no .hl7 files"
    end

    test "fixture file count matches the compile-time frozen list" do
      {:ok, entries} = File.ls(@fixture_dir)
      on_disk = entries |> Enum.filter(&String.ends_with?(&1, ".hl7")) |> length()
      frozen = length(HL7v2.Conformance.Fixtures.list_fixtures())

      assert on_disk == frozen,
             "on-disk fixture count (#{on_disk}) != frozen list (#{frozen}). " <>
               "Recompile HL7v2.Conformance.Fixtures after adding/removing fixtures."
    end
  end

  describe "built tarball includes conformance corpus" do
    @tag timeout: 60_000
    test "mix hex.build tarball .hl7 count matches frozen fixture count" do
      # Build into a temp dir so we never mutate the project root.
      tmp_dir = Path.join(System.tmp_dir!(), "hl7v2_pkg_test_#{:rand.uniform(1_000_000)}")
      File.mkdir_p!(tmp_dir)

      project_dir = Mix.Project.config()[:lockfile] |> Path.dirname()
      version = Mix.Project.config()[:version]

      tarball_path = Path.join(tmp_dir, "hl7v2-#{version}.tar")
      {_output, 0} = System.cmd("mix", ["hex.build", "--output", tarball_path], cd: project_dir)

      assert File.exists?(tarball_path),
             "expected #{tarball_path} but mix hex.build did not produce it"

      # Extract contents.tar.gz using argument lists (safe for paths with spaces)
      contents_gz = Path.join(tmp_dir, "contents.tar.gz")
      {_, 0} = System.cmd("tar", ["-xf", tarball_path, "-C", tmp_dir, "contents.tar.gz"])

      assert File.exists?(contents_gz), "contents.tar.gz not found inside tarball"

      {listing, 0} = System.cmd("tar", ["-tzf", contents_gz])

      hl7_count =
        listing
        |> String.split("\n")
        |> Enum.count(fn line ->
          String.contains?(line, "conformance/") and String.ends_with?(line, ".hl7")
        end)

      frozen_count = length(HL7v2.Conformance.Fixtures.list_fixtures())

      # Clean up temp dir — never touches the project root
      File.rm_rf!(tmp_dir)

      assert hl7_count == frozen_count,
             "tarball contains #{hl7_count} .hl7 files but frozen list has #{frozen_count}"
    end
  end
end
