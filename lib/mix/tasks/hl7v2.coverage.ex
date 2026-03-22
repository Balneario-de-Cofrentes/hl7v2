defmodule Mix.Tasks.Hl7v2.Coverage do
  @moduledoc """
  Prints HL7 v2.5.1 coverage report for the hl7v2 library.

  ## Usage

      mix hl7v2.coverage

  """

  use Mix.Task

  @shortdoc "Print HL7 v2.5.1 standards coverage report"

  @impl Mix.Task
  def run(_args) do
    summary = HL7v2.Standard.Coverage.coverage_summary()

    Mix.shell().info("""

    HL7v2 Library — v2.5.1 Coverage Report
    =======================================

    Segments:  #{summary.typed_segment_count} / #{summary.total_segment_count} standard (#{summary.segment_coverage_pct}%)
    Types:     #{summary.typed_type_count} / #{summary.total_type_count} standard (#{summary.type_coverage_pct}%)
    Fields:    #{summary.total_typed_fields} declared across typed segments
    Raw holes: #{summary.raw_hole_count}
    """)

    if summary.raw_hole_count > 0 do
      Mix.shell().info("  Raw Holes (fields typed as :raw in otherwise typed segments):")

      for {seg, field, seq} <- summary.raw_holes do
        Mix.shell().info("    #{seg}-#{seq} (#{field})")
      end

      Mix.shell().info("")
    end

    Mix.shell().info("  Typed Segments: #{Enum.join(HL7v2.Standard.Coverage.typed_segments(), ", ")}")
    Mix.shell().info("")

    unsupported = HL7v2.Standard.Coverage.unsupported_types()

    if length(unsupported) > 0 do
      Mix.shell().info("  Unsupported Types: #{Enum.join(unsupported, ", ")}")
      Mix.shell().info("")
    end
  end
end
