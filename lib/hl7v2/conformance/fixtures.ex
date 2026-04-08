defmodule HL7v2.Conformance.Fixtures do
  @moduledoc """
  Conformance fixture corpus statistics.

  The canonical structure list and fixture filenames are **frozen at compile
  time** by walking the fixture directory and extracting MSH-9 from each wire
  file. This means:

  - `coverage/0`, `list_fixtures/0`, and `unique_canonical_structures/0` return
    identical results whether running from source or from an installed Hex
    artifact (no runtime disk access required).
  - Changing any fixture file triggers recompilation via `@external_resource`.
  - Canonical resolution uses the same fallback logic as
    `HL7v2.Validation` — if the trigger-specific structure is unregistered,
    the bare message_code is tried before giving up. This correctly reports
    `ACK` for `ACK^A01^ACK_A01`, not the unregistered `ACK_A01`.

  This module is the single source of truth for fixture corpus counts
  reported in docs, CHANGELOG, and `mix hl7v2.coverage`.
  """

  @fixture_dir Path.expand("../../../test/fixtures/conformance", __DIR__)
  @total_official 186

  @fixtures (case File.ls(@fixture_dir) do
               {:ok, entries} ->
                 entries |> Enum.filter(&String.ends_with?(&1, ".hl7")) |> Enum.sort()

               _ ->
                 []
             end)

  # Recompile this module whenever any fixture file changes.
  for file <- @fixtures do
    @external_resource Path.join(@fixture_dir, file)
  end

  # Compile-time canonical resolution. Extracts MSH-9 via lightweight string
  # parsing (no dependency on the full parser at compile time) and applies
  # the same alias fallback as the validator.
  @frozen_canonical @fixtures
                    |> Enum.map(fn file ->
                      path = Path.join(@fixture_dir, file)
                      {:ok, content} = File.read(path)

                      first_line =
                        content
                        |> String.split(["\r", "\n"], trim: true)
                        |> List.first() || ""

                      fields = String.split(first_line, "|")
                      msh9 = Enum.at(fields, 8, "")
                      parts = String.split(msh9, "^")
                      code = Enum.at(parts, 0, "")
                      event = Enum.at(parts, 1, "")

                      resolved = HL7v2.MessageDefinition.canonical_structure(code, event)

                      cond do
                        HL7v2.Standard.MessageStructure.get(resolved) != nil ->
                          resolved

                        HL7v2.Standard.MessageStructure.get(code) != nil ->
                          code

                        true ->
                          nil
                      end
                    end)
                    |> Enum.reject(&is_nil/1)
                    |> Enum.uniq()
                    |> Enum.sort()

  @frozen_families @frozen_canonical
                   |> Enum.map(fn name ->
                     name |> String.split("_") |> List.first()
                   end)
                   |> Enum.uniq()
                   |> Enum.sort()

  @type coverage :: %{
          files: non_neg_integer(),
          canonical: non_neg_integer(),
          total_official: non_neg_integer(),
          pct: float()
        }

  @doc """
  Returns a map summarizing the conformance fixture corpus.

  - `:files` — number of `.hl7` fixture files
  - `:canonical` — number of unique canonical message structures covered
  - `:total_official` — 186 (HL7 v2.5.1 official structures)
  - `:pct` — canonical / total_official as a percentage, rounded to 1 decimal
  """
  @spec coverage() :: coverage()
  def coverage do
    %{
      files: length(@fixtures),
      canonical: length(@frozen_canonical),
      total_official: @total_official,
      pct: Float.round(length(@frozen_canonical) / @total_official * 100, 1)
    }
  end

  @doc """
  Returns the sorted list of fixture filenames included in the corpus.
  """
  @spec list_fixtures() :: [binary()]
  def list_fixtures, do: @fixtures

  @doc """
  Returns the sorted deduplicated list of canonical message structures
  covered by the corpus. Uses the same alias fallback as validation, so
  `ACK^A01^ACK_A01` resolves to the registered `ACK` structure rather than
  the unregistered `ACK_A01`.

  The `files` argument is ignored and kept for backwards compatibility —
  the result is frozen at compile time regardless of input.
  """
  @spec unique_canonical_structures([binary()]) :: [binary()]
  def unique_canonical_structures(_files \\ nil), do: @frozen_canonical

  @doc """
  Returns the sorted list of message family prefixes covered by the corpus
  (e.g. `"ADT"`, `"ORU"`, `"MFN"`). Derived from canonical structure names.
  """
  @spec families() :: [binary()]
  def families, do: @frozen_families

  @doc """
  Compares the compile-time-frozen fixture list against the current on-disk
  state of the fixture directory.

  Returns `:ok` if they match, or `{:stale, on_disk_only: [...], frozen_only: [...]}`
  when a mismatch is detected. Useful for dev/test guards to catch
  compile-time-frozen snapshots that lag the on-disk corpus after a file
  was added or removed without recompiling this module.

  Accepts options for dependency injection in tests:

  - `:dir` — override the directory to compare against (default: compile-time
    `@fixture_dir`)
  - `:frozen` — override the frozen list (default: compile-time `@fixtures`)

  Note: when called without options, this touches the filesystem and returns
  `:ok` if the fixture directory is not accessible (installed Hex artifact
  case with no corpus shipped).
  """
  @spec check_freshness(keyword()) :: :ok | {:stale, keyword()}
  def check_freshness(opts \\ []) do
    dir = Keyword.get(opts, :dir, @fixture_dir)
    frozen = Keyword.get(opts, :frozen, @fixtures)

    case File.ls(dir) do
      {:ok, entries} ->
        on_disk =
          entries
          |> Enum.filter(&String.ends_with?(&1, ".hl7"))
          |> MapSet.new()

        frozen_set = MapSet.new(frozen)

        on_disk_only = MapSet.difference(on_disk, frozen_set) |> MapSet.to_list() |> Enum.sort()
        frozen_only = MapSet.difference(frozen_set, on_disk) |> MapSet.to_list() |> Enum.sort()

        if on_disk_only == [] and frozen_only == [] do
          :ok
        else
          {:stale, on_disk_only: on_disk_only, frozen_only: frozen_only}
        end

      _ ->
        # Fixture dir not accessible (e.g. installed Hex artifact with no
        # corpus shipped) — nothing to compare against, so treat as fresh.
        :ok
    end
  end
end
