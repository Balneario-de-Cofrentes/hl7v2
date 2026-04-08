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
end
