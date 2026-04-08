defmodule HL7v2.Conformance.GeneratedStructureTest do
  @moduledoc """
  Programmatically generated structural validation tests for all 222 message
  structure definitions.

  For each structure, five tests are generated at compile time:

  1. **Positive — in order**: all required segments present in order -> no
     missing-segment errors from the structural validator.
  2. **MSH only fails**: only MSH supplied -> the validator reports at least
     one missing required segment.
  3. **Wrong order**: MSH + required segments in reverse -> validator reports
     at least one ordering/missing error (skipped for structures where every
     required segment can legitimately appear at multiple positions).
  4. **Non-repeating overflow**: a duplicated non-repeating required segment ->
     validator flags it (may be reported as cardinality, out-of-order, or
     unexpected depending on structure shape; this test only asserts *some*
     diagnostic is emitted). Skipped when no suitable segment exists.
  5. **Extra unknown segment**: an unknown segment ID injected -> validator
     either flags it or ignores it gracefully (regression guard against
     crashes on unrecognized IDs).
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

  # -- Helper: find a non-repeating required segment after MSH ------------------
  #
  # Returns the first required segment that is NOT marked :repeating (so
  # duplicating it must fail cardinality). Returns nil if every required
  # segment can repeat.
  @doc false
  def first_non_repeating_required(nodes), do: do_find_nonrep(nodes)

  defp do_find_nonrep([]), do: nil

  defp do_find_nonrep([{:segment, :MSH, _} | rest]), do: do_find_nonrep(rest)

  defp do_find_nonrep([{:segment, id, :required} | _]), do: id

  defp do_find_nonrep([{:segment, _, :required, :repeating} | rest]),
    do: do_find_nonrep(rest)

  defp do_find_nonrep([{:segment, _, :optional} | rest]),
    do: do_find_nonrep(rest)

  defp do_find_nonrep([{:segment, _, :optional, :repeating} | rest]),
    do: do_find_nonrep(rest)

  defp do_find_nonrep([{:group, _, :required, children} | rest]) when is_list(children),
    do: do_find_nonrep(children) || do_find_nonrep(rest)

  defp do_find_nonrep([{:group, _, :required, :repeating, _children} | rest]),
    do: do_find_nonrep(rest)

  defp do_find_nonrep([{:group, _, :optional, _children} | rest]),
    do: do_find_nonrep(rest)

  defp do_find_nonrep([{:group, _, :optional, :repeating, _children} | rest]),
    do: do_find_nonrep(rest)

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

      test "flags wrong order when MSH is not first (strict mode)" do
        structure = MessageStructure.get(unquote(name))
        required = unquote(__MODULE__).extract_required_ordered(structure.nodes)
        segment_ids = Enum.map(required, &Atom.to_string/1)

        # Move MSH to the end — universally invalid
        [_msh | rest] = segment_ids
        scrambled = rest ++ ["MSH"]

        errors = Structural.validate(structure, scrambled, mode: :strict)

        assert Enum.any?(errors, &(&1.level == :error)),
               "#{unquote(name)}: expected strict errors when MSH is not first, got #{inspect(errors)}"
      end

      test "flags duplicated non-repeating required segment (strict mode)" do
        structure = MessageStructure.get(unquote(name))
        required = unquote(__MODULE__).extract_required_ordered(structure.nodes)
        non_rep = unquote(__MODULE__).first_non_repeating_required(structure.nodes)

        if non_rep == nil do
          # Skip: every required segment can legitimately repeat
          :ok
        else
          segment_ids = Enum.map(required, &Atom.to_string/1)
          non_rep_str = Atom.to_string(non_rep)

          # Duplicate the non-repeating required segment
          duped = segment_ids ++ [non_rep_str]

          errors = Structural.validate(structure, duped, mode: :strict)

          # Strict mode should flag cardinality overflow as at least a warning
          # or error. We just need evidence the validator saw it.
          assert Enum.any?(errors, &(&1.level in [:error, :warning])),
                 "#{unquote(name)}: duplicating non-repeating #{non_rep_str} should be flagged"
        end
      end

      test "unknown segment does not crash the validator" do
        structure = MessageStructure.get(unquote(name))
        required = unquote(__MODULE__).extract_required_ordered(structure.nodes)
        segment_ids = Enum.map(required, &Atom.to_string/1)

        # Inject an unknown segment ID right after MSH
        [msh | rest] = segment_ids
        polluted = [msh, "ZZZ"] ++ rest

        # Should not raise; result shape must be a list of errors/warnings.
        errors = Structural.validate(structure, polluted)
        assert is_list(errors)
      end
    end
  end
end
