defmodule HL7v2.Conformance.GeneratedStructureTest do
  @moduledoc """
  Programmatically generated structural validation tests for all 222 message
  structure definitions.

  For each structure two tests are generated at compile time:

  1. **Positive** -- all required segments present in order -> no missing-segment
     errors from the structural validator.
  2. **Negative** -- only MSH supplied -> the validator reports at least one
     missing required segment (every structure requires more than MSH alone).
  """
  use ExUnit.Case, async: true

  alias HL7v2.Standard.MessageStructure
  alias HL7v2.Validation.Structural

  # -- Helper: extract required segments preserving duplicates and order --------
  #
  # `MessageStructure.required_segments/1` deduplicates, but structures like
  # ADT_A17 (Swap Patients) need PID+PV1 twice -- once per patient group.
  # Walking the AST preserves positional duplicates so the validator's
  # state-machine sees every expected occurrence.

  @doc false
  def extract_required_ordered(nodes), do: do_extract(nodes)

  defp do_extract([]), do: []

  defp do_extract([{:segment, id, :required} | rest]),
    do: [id | do_extract(rest)]

  defp do_extract([{:segment, id, :required, :repeating} | rest]),
    do: [id | do_extract(rest)]

  defp do_extract([{:segment, _, :optional} | rest]),
    do: do_extract(rest)

  defp do_extract([{:segment, _, :optional, :repeating} | rest]),
    do: do_extract(rest)

  defp do_extract([{:group, _, :required, children} | rest]),
    do: do_extract(children) ++ do_extract(rest)

  defp do_extract([{:group, _, :required, :repeating, children} | rest]),
    do: do_extract(children) ++ do_extract(rest)

  defp do_extract([{:group, _, :optional, _children} | rest]),
    do: do_extract(rest)

  defp do_extract([{:group, _, :optional, :repeating, _children} | rest]),
    do: do_extract(rest)

  # -- Generate test pairs for every defined structure -------------------------

  for name <- MessageStructure.names() do
    describe name do
      test "passes with all required segments" do
        structure = MessageStructure.get(unquote(name))
        required = unquote(__MODULE__).extract_required_ordered(structure.nodes)
        segment_ids = Enum.map(required, &Atom.to_string/1)

        errors = Structural.validate(structure, segment_ids)

        missing =
          Enum.filter(errors, fn e ->
            e.level == :error and String.contains?(e.message, "missing")
          end)

        assert missing == [],
               "#{unquote(name)}: expected no missing-segment errors, got #{inspect(missing)}"
      end

      test "fails with MSH only" do
        structure = MessageStructure.get(unquote(name))
        required = unquote(__MODULE__).extract_required_ordered(structure.nodes)

        # Every structure requires at least 2 segments (MSH + others).
        assert length(required) > 1,
               "#{unquote(name)}: expected >1 required segments, got #{inspect(required)}"

        errors = Structural.validate(structure, ["MSH"])

        missing =
          Enum.filter(errors, fn e ->
            e.level == :error and String.contains?(e.message, "missing")
          end)

        assert length(missing) > 0,
               "#{unquote(name)}: should report missing required segments when given MSH only"
      end
    end
  end
end
