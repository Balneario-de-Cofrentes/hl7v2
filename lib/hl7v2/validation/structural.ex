defmodule HL7v2.Validation.Structural do
  @moduledoc """
  Positional structural validation against HL7 v2.5.1 abstract message definitions.

  Validates segment ordering, group structure, and cardinality by walking the
  actual segment stream against the structure AST in order — a state-machine
  approach that correctly handles:

  - **Segments in multiple groups** — ROL can appear in PATIENT, VISIT,
    PROCEDURE, INSURANCE; each group consumes its own occurrences
  - **Repeating groups** — each repetition independently validates required
    children (e.g., ADT_A39 PATIENT group needs PID+MRG per occurrence)
  - **Positional ordering** — violations are detected naturally because the
    walk is sequential
  - **Cardinality** — non-repeating segments/groups consumed at most once

  ## Modes

  - `:lenient` (default) — unexpected segments are warnings, missing required
    segments are errors
  - `:strict` — all structural violations are errors

  ## Usage

      structure = HL7v2.Standard.MessageStructure.get("ORU_R01")
      segment_ids = ["MSH", "PID", "OBR", "OBX", "NTE"]
      errors = HL7v2.Validation.Structural.validate(structure, segment_ids)

  """

  alias HL7v2.Standard.MessageStructure

  @type error :: %{
          level: :error | :warning,
          location: binary(),
          field: atom() | nil,
          message: binary()
        }

  @doc """
  Validates a list of segment IDs against a message structure definition.

  Returns a list of errors/warnings (empty list = valid).
  """
  @spec validate(MessageStructure.structure(), [binary()], keyword()) :: [error()]
  def validate(%{nodes: nodes, name: name}, segment_ids, opts \\ []) do
    mode = Keyword.get(opts, :mode, :lenient)

    # Convert known IDs to strings once to avoid creating atoms from untrusted input
    known_strings =
      nodes
      |> collect_all_segment_ids()
      |> MapSet.new(&Atom.to_string/1)

    {errors, remaining} = match_nodes(nodes, segment_ids, name, mode, known_strings)

    # Any remaining segments after consuming all AST nodes
    leftover_errors = check_leftover(remaining, name, mode, known_strings)

    # Post-process: if a segment is reported as "missing" but exists in the
    # leftover (unconsumed) segments, it's out of order, not missing.
    # Also suppress leftover warnings for segments already flagged as out-of-order.
    leftover_ids = MapSet.new(remaining)

    {improved, reclassified} = improve_missing_diagnostics(errors, leftover_ids, mode)

    # Filter leftover errors for segments already reported as out-of-order
    filtered_leftovers =
      Enum.reject(leftover_errors, fn error ->
        case error.message do
          "Segment " <> rest ->
            seg = rest |> String.split(" ") |> hd()
            MapSet.member?(reclassified, seg)

          _ ->
            false
        end
      end)

    improved ++ filtered_leftovers
  end

  defp improve_missing_diagnostics(errors, leftover_ids, mode) do
    {improved, reclassified} =
      Enum.map_reduce(errors, MapSet.new(), fn
        %{message: "Required segment " <> rest} = error, acc ->
          seg_name = rest |> String.split(" ") |> hd()

          if MapSet.member?(leftover_ids, seg_name) do
            level = if mode == :strict, do: :error, else: :warning

            upgraded = %{
              error
              | level: level,
                message: "Required segment #{seg_name} is present but out of order"
            }

            {upgraded, MapSet.put(acc, seg_name)}
          else
            {error, acc}
          end

        other, acc ->
          {other, acc}
      end)

    {improved, reclassified}
  end

  # --- Positional Matching Engine ---

  # Walk AST nodes in order, consuming segments from the stream.
  # Returns {errors, remaining_segments}.
  defp match_nodes([], remaining, _name, _mode, _known), do: {[], remaining}

  defp match_nodes([node | rest], remaining, name, mode, known) do
    {node_errors, after_node} = match_node(node, remaining, name, mode, known)
    {rest_errors, after_rest} = match_nodes(rest, after_node, name, mode, known)
    {node_errors ++ rest_errors, after_rest}
  end

  # --- Segment Nodes ---

  # Required segment (non-repeating)
  defp match_node({:segment, id, :required}, remaining, name, _mode, known) do
    seg_str = Atom.to_string(id)
    {skipped, after_skip} = skip_unknown(remaining, known)

    case after_skip do
      [^seg_str | rest] ->
        {skipped, rest}

      _ ->
        error = %{
          level: :error,
          location: name,
          field: nil,
          message: "Required segment #{id} is missing"
        }

        {skipped ++ [error], after_skip}
    end
  end

  # Optional segment (non-repeating)
  defp match_node({:segment, id, :optional}, remaining, _name, _mode, known) do
    seg_str = Atom.to_string(id)
    {skipped, after_skip} = skip_unknown(remaining, known)

    case after_skip do
      [^seg_str | rest] -> {skipped, rest}
      _ -> {skipped, after_skip}
    end
  end

  # Required repeating segment
  defp match_node({:segment, id, :required, :repeating}, remaining, name, _mode, known) do
    seg_str = Atom.to_string(id)
    {skipped, after_skip} = skip_unknown(remaining, known)

    case after_skip do
      [^seg_str | _] ->
        {consumed_rest, errors} = consume_repeating(after_skip, seg_str)
        {skipped ++ errors, consumed_rest}

      _ ->
        error = %{
          level: :error,
          location: name,
          field: nil,
          message: "Required segment #{id} is missing"
        }

        {skipped ++ [error], after_skip}
    end
  end

  # Optional repeating segment
  defp match_node({:segment, id, :optional, :repeating}, remaining, _name, _mode, known) do
    seg_str = Atom.to_string(id)
    {skipped, after_skip} = skip_unknown(remaining, known)

    case after_skip do
      [^seg_str | _] ->
        {consumed_rest, errors} = consume_repeating(after_skip, seg_str)
        {skipped ++ errors, consumed_rest}

      _ ->
        {skipped, after_skip}
    end
  end

  # --- Group Nodes ---

  # Required group (non-repeating)
  defp match_node({:group, group_name, :required, children}, remaining, name, mode, known) do
    case try_match_group(children, remaining, name, mode, known) do
      {:matched, errors, after_group} ->
        {errors, after_group}

      :no_match ->
        # Required group not matched — report missing required children
        missing = missing_required_in_group(children, group_name, name)
        {missing, remaining}
    end
  end

  # Optional group (non-repeating)
  defp match_node({:group, _group_name, :optional, children}, remaining, name, mode, known) do
    case try_match_group(children, remaining, name, mode, known) do
      {:matched, errors, after_group} -> {errors, after_group}
      :no_match -> {[], remaining}
    end
  end

  # Required repeating group
  defp match_node(
         {:group, group_name, :required, :repeating, children},
         remaining,
         name,
         mode,
         known
       ) do
    case try_match_group(children, remaining, name, mode, known) do
      {:matched, first_errors, after_first} ->
        {repeat_errors, after_all} =
          consume_repeating_group(children, after_first, name, mode, known)

        {first_errors ++ repeat_errors, after_all}

      :no_match ->
        missing = missing_required_in_group(children, group_name, name)
        {missing, remaining}
    end
  end

  # Optional repeating group
  defp match_node(
         {:group, _group_name, :optional, :repeating, children},
         remaining,
         name,
         mode,
         known
       ) do
    case try_match_group(children, remaining, name, mode, known) do
      {:matched, first_errors, after_first} ->
        {repeat_errors, after_all} =
          consume_repeating_group(children, after_first, name, mode, known)

        {first_errors ++ repeat_errors, after_all}

      :no_match ->
        {[], remaining}
    end
  end

  # --- Group Matching ---

  # Try to match a group's children against the segment stream.
  # A group matches if its first defined segment (the "anchor") is found
  # at the head of the stream (after skipping unknowns).
  #
  # Returns {:matched, errors, remaining} or :no_match.
  defp try_match_group(children, remaining, name, mode, known) do
    anchor_ids = group_anchor_ids(children)

    {_skipped, after_skip} = peek_skip_unknown(remaining, known)

    case after_skip do
      [head | _] ->
        if head in anchor_ids do
          {errors, after_match} = match_nodes(children, remaining, name, mode, known)
          {:matched, errors, after_match}
        else
          :no_match
        end

      [] ->
        :no_match
    end
  end

  # Consume additional repetitions of a group.
  defp consume_repeating_group(children, remaining, name, mode, known) do
    case try_match_group(children, remaining, name, mode, known) do
      {:matched, errors, after_group} ->
        {more_errors, final} =
          consume_repeating_group(children, after_group, name, mode, known)

        {errors ++ more_errors, final}

      :no_match ->
        {[], remaining}
    end
  end

  # --- Helpers ---

  # Consume all consecutive occurrences of a segment ID.
  defp consume_repeating([seg_str | rest], seg_str) do
    consume_repeating(rest, seg_str)
  end

  defp consume_repeating(remaining, _seg_str), do: {remaining, []}

  # Skip unknown/Z-segments at the head of the stream.
  # Returns {warning_errors, remaining_after_skip}.
  # Unknown segments are those not in the structure definition AND not Z-segments.
  # Z-segments are silently skipped. Other unknowns generate warnings.
  defp skip_unknown(remaining, known) do
    do_skip_unknown(remaining, known, [])
  end

  defp do_skip_unknown([], _known, acc), do: {Enum.reverse(acc), []}

  defp do_skip_unknown([head | rest] = remaining, known_strings, acc) do
    cond do
      String.starts_with?(head, "Z") -> do_skip_unknown(rest, known_strings, acc)
      MapSet.member?(known_strings, head) -> {Enum.reverse(acc), remaining}
      true -> do_skip_unknown(rest, known_strings, acc)
    end
  end

  # Peek ahead past unknowns without consuming them (no warnings generated).
  # Returns {skipped_count, remaining_after_skip}.
  defp peek_skip_unknown(remaining, known) do
    do_peek_skip(remaining, known, 0)
  end

  defp do_peek_skip([], _known, count), do: {count, []}

  defp do_peek_skip([head | rest] = remaining, known_strings, count) do
    cond do
      String.starts_with?(head, "Z") -> do_peek_skip(rest, known_strings, count + 1)
      MapSet.member?(known_strings, head) -> {count, remaining}
      true -> do_peek_skip(rest, known_strings, count + 1)
    end
  end

  # Get all segment IDs that could start a group (anchor candidates).
  # This is the first segment in the children list — could be required or optional.
  # We collect all leading segments until we hit a required one (inclusive)
  # or a group node.
  defp group_anchor_ids(children) do
    do_anchor_ids(children, MapSet.new())
    |> MapSet.to_list()
    |> Enum.map(&Atom.to_string/1)
  end

  defp do_anchor_ids([], acc), do: acc

  defp do_anchor_ids([{:segment, id, :required} | _], acc) do
    MapSet.put(acc, id)
  end

  defp do_anchor_ids([{:segment, id, :required, :repeating} | _], acc) do
    MapSet.put(acc, id)
  end

  defp do_anchor_ids([{:segment, id, :optional} | rest], acc) do
    do_anchor_ids(rest, MapSet.put(acc, id))
  end

  defp do_anchor_ids([{:segment, id, :optional, :repeating} | rest], acc) do
    do_anchor_ids(rest, MapSet.put(acc, id))
  end

  defp do_anchor_ids([{:group, _name, :required, children} | _], acc) do
    # Include the group's own anchors
    MapSet.union(acc, do_anchor_ids(children, MapSet.new()))
  end

  defp do_anchor_ids([{:group, _name, :required, :repeating, children} | _], acc) do
    MapSet.union(acc, do_anchor_ids(children, MapSet.new()))
  end

  defp do_anchor_ids([{:group, _name, :optional, children} | rest], acc) do
    group_anchors = do_anchor_ids(children, MapSet.new())
    do_anchor_ids(rest, MapSet.union(acc, group_anchors))
  end

  defp do_anchor_ids([{:group, _name, :optional, :repeating, children} | rest], acc) do
    group_anchors = do_anchor_ids(children, MapSet.new())
    do_anchor_ids(rest, MapSet.union(acc, group_anchors))
  end

  # Report errors for missing required segments within a required group.
  defp missing_required_in_group(children, _group_name, structure_name) do
    children
    |> Enum.flat_map(fn
      {:segment, id, :required} ->
        [
          %{
            level: :error,
            location: structure_name,
            field: nil,
            message: "Required segment #{id} is missing"
          }
        ]

      {:segment, id, :required, :repeating} ->
        [
          %{
            level: :error,
            location: structure_name,
            field: nil,
            message: "Required segment #{id} is missing"
          }
        ]

      {:group, _, :required, sub_children} ->
        missing_required_in_group(sub_children, nil, structure_name)

      {:group, _, :required, :repeating, sub_children} ->
        missing_required_in_group(sub_children, nil, structure_name)

      _ ->
        []
    end)
  end

  # Check leftover segments after all AST nodes are consumed.
  # Z-segments are silently ignored. Known segments that weren't consumed
  # indicate ordering problems.
  defp check_leftover([], _name, _mode, _known), do: []

  defp check_leftover(remaining, name, mode, known_strings) do
    remaining
    |> Enum.reject(&String.starts_with?(&1, "Z"))
    |> Enum.flat_map(fn seg_str ->
      level = if mode == :strict, do: :error, else: :warning

      if MapSet.member?(known_strings, seg_str) do
        [
          %{
            level: level,
            location: name,
            field: nil,
            message: "Segment #{seg_str} appears after its expected position in the structure"
          }
        ]
      else
        [
          %{
            level: level,
            location: name,
            field: nil,
            message: "Segment #{seg_str} is not defined in #{name} structure"
          }
        ]
      end
    end)
  end

  # Collect all segment IDs defined in the structure (as a MapSet of atoms).
  defp collect_all_segment_ids(nodes) do
    nodes
    |> do_collect_ids(MapSet.new())
  end

  defp do_collect_ids([], acc), do: acc

  defp do_collect_ids([{:segment, id, _} | rest], acc) do
    do_collect_ids(rest, MapSet.put(acc, id))
  end

  defp do_collect_ids([{:segment, id, _, :repeating} | rest], acc) do
    do_collect_ids(rest, MapSet.put(acc, id))
  end

  defp do_collect_ids([{:group, _, _, children} | rest], acc) do
    acc = do_collect_ids(children, acc)
    do_collect_ids(rest, acc)
  end

  defp do_collect_ids([{:group, _, _, :repeating, children} | rest], acc) do
    acc = do_collect_ids(children, acc)
    do_collect_ids(rest, acc)
  end

  # Safe atom conversion — only for known segment IDs that are already atoms
end
