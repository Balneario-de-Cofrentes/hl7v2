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
    test "mix hex.build tarball contains .hl7 fixture files" do
      project_dir = Mix.Project.config()[:lockfile] |> Path.dirname()
      {_output, 0} = System.cmd("mix", ["hex.build"], cd: project_dir)

      # Find the built tarball
      tarball =
        project_dir
        |> File.ls!()
        |> Enum.find(&String.match?(&1, ~r/^hl7v2-.*\.tar$/))

      assert tarball, "mix hex.build did not produce a .tar file"
      tarball_path = Path.join(project_dir, tarball)

      # Pipe: extract contents.tar.gz from outer tar, then list its entries
      tmp = Path.join(System.tmp_dir!(), "hl7v2_pkg_#{:rand.uniform(1_000_000)}.tar.gz")
      {_, 0} = System.cmd("sh", ["-c", "tar -xOf #{tarball_path} contents.tar.gz > #{tmp}"])
      {listing, 0} = System.cmd("tar", ["-tzf", tmp])

      hl7_count =
        listing
        |> String.split("\n")
        |> Enum.count(fn line ->
          String.contains?(line, "conformance/") and String.ends_with?(line, ".hl7")
        end)

      # Clean up
      File.rm(tmp)
      File.rm(tarball_path)

      assert hl7_count >= 110,
             "tarball contains #{hl7_count} .hl7 files, expected >= 110"
    end
  end
end
