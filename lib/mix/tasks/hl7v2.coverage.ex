defmodule Mix.Tasks.Hl7v2.Coverage do
  @moduledoc """
  Prints HL7 v2.5.1 coverage report for the hl7v2 library.

  ## Usage

      mix hl7v2.coverage
      mix hl7v2.coverage --detail    # include per-segment field completeness

  """

  use Mix.Task

  @shortdoc "Print HL7 v2.5.1 standards coverage report"

  @impl Mix.Task
  def run(args) do
    # Start :telemetry so any runtime paths that emit telemetry events
    # (parser, MLLP, validation) don't log "handlers not found" warnings.
    {:ok, _} = Application.ensure_all_started(:telemetry)

    summary = HL7v2.Standard.Coverage.coverage_summary()
    fully = HL7v2.Standard.Coverage.fully_typed_segments()
    partial = HL7v2.Standard.Coverage.partially_typed_segments()

    Mix.shell().info("""

    HL7v2 Library — v2.5.1 Coverage Report
    =======================================

    Segments:  #{summary.typed_segment_count} / #{summary.total_segment_count} standard (#{summary.segment_coverage_pct}%)
               #{length(fully)} fully typed, #{length(partial)} with raw holes
    Types:     #{summary.typed_type_count - 1} official v2.5.1 + 1 legacy TN (#{summary.typed_type_count} total)
    Fields:    #{summary.total_typed_fields} declared across typed segments
    Raw holes: #{summary.raw_hole_count} true gaps#{runtime_dispatched_label(summary)}
    """)

    if "--detail" in args do
      Mix.shell().info("  Per-Segment Field Completeness:")

      Mix.shell().info(
        "  #{String.pad_trailing("Segment", 8)} #{String.pad_trailing("Typed", 8)} #{String.pad_trailing("Total", 8)} Complete"
      )

      Mix.shell().info("  #{String.duplicate("-", 40)}")

      for {seg, typed, total, pct} <- HL7v2.Standard.Coverage.segment_completeness() do
        marker = if pct == 100.0, do: "", else: " *"

        Mix.shell().info(
          "  #{String.pad_trailing(seg, 8)} #{String.pad_trailing("#{typed}", 8)} #{String.pad_trailing("#{total}", 8)} #{pct}%#{marker}"
        )
      end

      Mix.shell().info("")
    end

    if summary.runtime_dispatched_count > 0 do
      Mix.shell().info("  Runtime-dispatched (intentionally raw):")

      for {seg, field, seq} <- summary.runtime_dispatched do
        Mix.shell().info("    #{seg}-#{seq} :#{field}")
      end

      Mix.shell().info("")
    end

    if summary.raw_hole_count > 0 and "--detail" not in args do
      Mix.shell().info("  Run with --detail for per-segment field completeness")
      Mix.shell().info("")
    end

    Mix.shell().info("  Fully Typed: #{Enum.join(fully, ", ")}")

    if length(partial) > 0 do
      Mix.shell().info("  Partial (*):  #{Enum.join(partial, ", ")}")
    end

    Mix.shell().info("")
    print_fixture_coverage()
  end

  defp print_fixture_coverage do
    case HL7v2.Conformance.Fixtures.coverage() do
      %{files: 0} ->
        :ok

      %{files: files, canonical: canonical, total_official: total, pct: pct} ->
        Mix.shell().info("""
          Fixture Corpus:
            #{files} wire fixtures
            #{canonical} unique canonical structures
            #{pct}% of #{total} official v2.5.1 structures
        """)
    end
  end

  defp runtime_dispatched_label(%{runtime_dispatched_count: 0}), do: ""

  defp runtime_dispatched_label(%{runtime_dispatched_count: n}),
    do: ", #{n} runtime-dispatched"
end
