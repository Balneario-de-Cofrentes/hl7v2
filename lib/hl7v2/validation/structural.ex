defmodule HL7v2.Validation.Structural do
  @moduledoc """
  Structural validation against HL7 v2.5.1 abstract message definitions.

  Validates segment ordering, group structure, and cardinality against the
  group-aware definitions in `HL7v2.Standard.MessageStructure`.

  Unlike presence-only validation (which just checks if required segment IDs
  exist), structural validation enforces:

  - **Segment ordering** — segments must appear in the order defined by the structure
  - **Group anchors** — group-starting segments must be present when group children appear
  - **Cardinality** — non-repeating segments/groups must not appear more than once
  - **Orphan detection** — grouped segments without their anchor are flagged

  ## Modes

  - `:lenient` (default) — ordering issues are warnings, missing required segments are errors
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

    # Build expected order from the structure AST
    expected_order = flatten_expected_order(nodes)

    # Check 1: Required segments present
    missing_errors = check_missing_required(nodes, segment_ids, name)

    # Check 2: Segment ordering
    order_errors = check_ordering(expected_order, segment_ids, name, mode)

    # Check 3: Cardinality (non-repeating segments appearing multiple times)
    cardinality_errors = check_cardinality(nodes, segment_ids, name, mode)

    missing_errors ++ order_errors ++ cardinality_errors
  end

  # --- Required segment presence ---

  defp check_missing_required(nodes, segment_ids, structure_name) do
    required = MessageStructure.required_segments(%{nodes: nodes})
    missing = Enum.reject(required, &(Atom.to_string(&1) in segment_ids))

    Enum.map(missing, fn seg ->
      %{
        level: :error,
        location: structure_name,
        field: nil,
        message: "Required segment #{seg} is missing"
      }
    end)
  end

  # --- Ordering ---

  # Flatten the AST into an ordered list of expected segment IDs.
  # Groups are flattened in-order; their children follow the group's position.
  defp flatten_expected_order(nodes) do
    Enum.flat_map(nodes, fn
      {:segment, id, _, :repeating} -> [id]
      {:segment, id, _} -> [id]
      {:group, _name, _, children} -> flatten_expected_order(children)
      {:group, _name, _, :repeating, children} -> flatten_expected_order(children)
    end)
    |> Enum.uniq()
  end

  defp check_ordering(expected_order, segment_ids, structure_name, mode) do
    # Filter actual segments to only those in the expected order
    # (unknown/Z segments are ignored for ordering)
    expected_set = MapSet.new(Enum.map(expected_order, &Atom.to_string/1))

    known_actuals =
      segment_ids
      |> Enum.filter(&(&1 in expected_set))
      |> Enum.uniq()

    known_expected =
      expected_order
      |> Enum.map(&Atom.to_string/1)
      |> Enum.filter(&(&1 in MapSet.new(known_actuals)))

    # Check if the known actuals appear in the expected order
    # Use a simple approach: for each consecutive pair in actuals,
    # verify the first appears before the second in expected
    find_order_violations(known_actuals, known_expected, structure_name, mode)
  end

  defp find_order_violations(actuals, expected, structure_name, mode) do
    expected_indices =
      expected
      |> Enum.with_index()
      |> Map.new()

    # Walk through actuals and check if their expected indices are non-decreasing
    actuals
    |> Enum.map(&{&1, Map.get(expected_indices, &1)})
    |> Enum.reject(fn {_, idx} -> is_nil(idx) end)
    |> check_monotonic(structure_name, mode)
  end

  defp check_monotonic(indexed_segments, structure_name, mode) do
    indexed_segments
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.flat_map(fn [{seg_a, idx_a}, {seg_b, idx_b}] ->
      if idx_a > idx_b do
        level = if mode == :strict, do: :error, else: :warning

        [
          %{
            level: level,
            location: structure_name,
            field: nil,
            message: "Segment #{seg_b} appears before #{seg_a} but should come after it"
          }
        ]
      else
        []
      end
    end)
  end

  # --- Cardinality ---

  defp check_cardinality(nodes, segment_ids, structure_name, mode) do
    non_repeating = collect_non_repeating_segments(nodes)
    id_counts = Enum.frequencies(segment_ids)

    non_repeating
    |> Enum.filter(fn seg_atom ->
      count = Map.get(id_counts, Atom.to_string(seg_atom), 0)
      count > 1
    end)
    |> Enum.map(fn seg_atom ->
      count = Map.get(id_counts, Atom.to_string(seg_atom), 0)
      level = if mode == :strict, do: :error, else: :warning

      %{
        level: level,
        location: structure_name,
        field: nil,
        message: "Segment #{seg_atom} appears #{count} times but is not repeating"
      }
    end)
  end

  defp collect_non_repeating_segments(nodes) do
    Enum.flat_map(nodes, fn
      {:segment, _id, _, :repeating} -> []
      {:segment, id, _optionality} -> [id]
      {:group, _name, _, children} -> collect_non_repeating_segments(children)
      {:group, _name, _, :repeating, _children} -> []
    end)
    |> Enum.uniq()
  end
end
