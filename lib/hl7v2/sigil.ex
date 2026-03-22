defmodule HL7v2.Sigil do
  @moduledoc """
  Compile-time validated HL7v2 path sigil.

  The `~h` sigil validates path syntax and segment/field existence at compile time,
  catching typos before the code runs. Returns a `%HL7v2.Path{}` struct that can be
  passed to `HL7v2.get/2` and `HL7v2.fetch/2`.

  ## Usage

      import HL7v2.Sigil

      path = ~h"PID-5"        # validated at compile time
      name = HL7v2.get(msg, path)

      ~h"PID-55"              # ** (CompileError) PID has 39 fields, got 55
      ~h"XXX-1"               # warning: unknown segment XXX (not compile error — may be valid)

  ## Path Syntax

      ~h"PID"          — segment
      ~h"PID-5"        — field 5
      ~h"PID-5.1"      — component 1 of field 5
      ~h"PID-3[2]"     — repetition 2 of field 3
      ~h"OBX[*]-5"     — field 5 from ALL OBX segments
      ~h"OBX[2]-5"     — field 5 from the 2nd OBX segment
      ~h"PID-3[*]"     — ALL repetitions of PID-3

  """

  alias HL7v2.Path

  @doc """
  Sigil for compile-time validated HL7v2 paths.

  Returns a `%HL7v2.Path{}` struct. Path syntax is validated at compile time,
  and known segments are checked for field bounds.
  """
  defmacro sigil_h(path_ast, _modifiers) do
    path_string =
      case path_ast do
        {:<<>>, _, [str]} when is_binary(str) -> str
        _ -> raise CompileError, description: "~h sigil requires a string literal"
      end

    case HL7v2.Access.parse_path(path_string) do
      {:error, :invalid_path} ->
        raise CompileError,
          description: "invalid HL7v2 path: #{inspect(path_string)}"

      {:ok, parsed} ->
        validate_at_compile_time!(parsed, path_string)

        Macro.escape(%Path{
          raw: path_string,
          segment: parsed.segment,
          segment_index: parsed.segment_index,
          field: parsed.field,
          component: parsed.component,
          repetition: parsed.repetition
        })
    end
  end

  defp validate_at_compile_time!(%{segment: seg_id, field: field_seq}, path_string) do
    segment_module = HL7v2.TypedParser.segment_module(seg_id)

    case segment_module do
      nil ->
        IO.warn(
          "unknown segment #{seg_id} in path #{inspect(path_string)} — will resolve at runtime"
        )

      module ->
        if field_seq != nil do
          fields = module.fields()

          max_seq =
            fields
            |> Enum.map(fn {seq, _, _, _, _} -> seq end)
            |> Enum.max(fn -> 0 end)

          unless Enum.any?(fields, fn {seq, _, _, _, _} -> seq == field_seq end) do
            raise CompileError,
              description:
                "#{seg_id} has #{max_seq} fields, got field #{field_seq} in path #{inspect(path_string)}"
          end
        end
    end
  end
end
