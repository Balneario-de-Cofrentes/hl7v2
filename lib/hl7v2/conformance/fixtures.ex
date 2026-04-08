defmodule HL7v2.Conformance.Fixtures do
  @moduledoc """
  Runtime helper that computes conformance fixture corpus statistics from
  the on-disk fixture directory.

  This exists as a single source of truth for fixture coverage numbers
  reported in docs, CHANGELOG, and `mix hl7v2.coverage` — so the published
  counts cannot drift from actual evidence on disk.
  """

  @fixture_dir Path.expand("../../../test/fixtures/conformance", __DIR__)
  @total_official 186

  @type coverage :: %{
          files: non_neg_integer(),
          canonical: non_neg_integer(),
          total_official: non_neg_integer(),
          pct: float()
        }

  @doc """
  Returns a map summarizing the conformance fixture corpus.

  - `:files` — number of `.hl7` fixture files on disk
  - `:canonical` — number of unique canonical message structures covered
  - `:total_official` — 186 (HL7 v2.5.1 official structures)
  - `:pct` — canonical / total_official as a percentage, rounded to 1 decimal
  """
  @spec coverage() :: coverage()
  def coverage do
    files = list_fixtures()
    canonical = unique_canonical_structures(files)
    pct = Float.round(length(canonical) / @total_official * 100, 1)

    %{
      files: length(files),
      canonical: length(canonical),
      total_official: @total_official,
      pct: pct
    }
  end

  @doc """
  Returns the sorted list of fixture filenames on disk.
  """
  @spec list_fixtures() :: [binary()]
  def list_fixtures do
    case File.ls(@fixture_dir) do
      {:ok, entries} ->
        entries
        |> Enum.filter(&String.ends_with?(&1, ".hl7"))
        |> Enum.sort()

      _ ->
        []
    end
  end

  @doc """
  Returns the sorted list of unique canonical structures covered by the
  on-disk fixture corpus.
  """
  @spec unique_canonical_structures([binary()]) :: [binary()]
  def unique_canonical_structures(files \\ list_fixtures()) do
    files
    |> Enum.map(&canonical_for_file/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp canonical_for_file(file) do
    path = Path.join(@fixture_dir, file)

    with {:ok, wire} <- File.read(path),
         {:ok, msg} <- HL7v2.parse(String.replace(wire, "\n", "\r"), mode: :typed) do
      msh = hd(msg.segments)
      type = msh.message_type

      HL7v2.MessageDefinition.canonical_structure(type.message_code, type.trigger_event)
    else
      _ -> nil
    end
  end
end
