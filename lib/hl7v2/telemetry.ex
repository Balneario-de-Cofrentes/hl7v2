defmodule HL7v2.Telemetry do
  @moduledoc """
  Telemetry event helpers for HL7v2 operations.

  All events are prefixed with `[:hl7v2, ...]`. Span events emit
  `[:hl7v2, event, :start]` and `[:hl7v2, event, :stop]` (or `:exception`).

  ## Events

  | Event | Measurements | Metadata |
  |-------|-------------|----------|
  | `[:hl7v2, :parse, :start]` | `%{system_time: integer}` | `%{mode: atom}` |
  | `[:hl7v2, :parse, :stop]` | `%{duration: integer}` | `%{mode: atom}` |
  | `[:hl7v2, :encode, :start]` | `%{system_time: integer}` | `%{type: atom}` |
  | `[:hl7v2, :encode, :stop]` | `%{duration: integer}` | `%{type: atom}` |
  """

  @doc """
  Executes a span with HL7v2 telemetry events.

  Emits `[:hl7v2, event, :start]` before and `[:hl7v2, event, :stop]` after
  the given function runs (or `[:hl7v2, event, :exception]` if it raises).
  """
  @spec span(atom(), map(), (-> result)) :: result when result: var
  def span(event, metadata, fun) do
    :telemetry.span(
      [:hl7v2, event],
      metadata,
      fn ->
        result = fun.()
        {result, metadata}
      end
    )
  end

  @doc """
  Emits a telemetry event with the given measurements and metadata.
  """
  @spec emit(atom(), map(), map()) :: :ok
  def emit(event, measurements \\ %{}, metadata \\ %{}) do
    :telemetry.execute([:hl7v2, event], measurements, metadata)
  end
end
