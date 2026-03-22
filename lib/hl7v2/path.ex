defmodule HL7v2.Path do
  @moduledoc """
  Represents a validated HL7v2 path.

  Created by the `~h` sigil at compile time or by `HL7v2.Path.parse/1` at runtime.
  Pass to `HL7v2.get/2` or `HL7v2.fetch/2` for resolution.

  ## Path Syntax

      "PID"          — segment
      "PID-5"        — field 5
      "PID-5.1"      — component 1 of field 5
      "PID-3[2]"     — repetition 2 of field 3

  """

  @enforce_keys [:raw, :segment]
  defstruct [:raw, :segment, :field, :component, :repetition]

  @type t :: %__MODULE__{
          raw: binary(),
          segment: binary(),
          field: pos_integer() | nil,
          component: pos_integer() | nil,
          repetition: pos_integer() | nil
        }

  @doc """
  Parses a path string at runtime, returning `{:ok, path}` or `{:error, :invalid_path}`.

  Prefer the `~h` sigil for compile-time validation when the path is a literal.
  """
  @spec parse(binary()) :: {:ok, t()} | {:error, :invalid_path}
  def parse(path) when is_binary(path) do
    case HL7v2.Access.parse_path(path) do
      {:ok, parsed} ->
        {:ok,
         %__MODULE__{
           raw: path,
           segment: parsed.segment,
           field: parsed.field,
           component: parsed.component,
           repetition: parsed.repetition
         }}

      {:error, _} = err ->
        err
    end
  end
end
