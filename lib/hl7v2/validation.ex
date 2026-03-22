defmodule HL7v2.Validation do
  @moduledoc """
  Validates HL7v2 typed messages.

  Opt-in validation that returns accumulated errors without blocking parsing.
  Call `validate/1` on a `HL7v2.TypedMessage` to check message-level and
  field-level rules.

  ## Examples

      {:ok, msg} = HL7v2.parse(text, mode: :typed)
      :ok = HL7v2.Validation.validate(msg)

      {:error, errors} = HL7v2.Validation.validate(invalid_msg)
      # errors is a list of %{level: :error | :warning, location: ..., field: ..., message: ...}

  """

  alias HL7v2.MessageDefinition
  alias HL7v2.TypedMessage
  alias HL7v2.Validation.{MessageRules, FieldRules}

  @doc """
  Validates a typed message.

  Returns `:ok` when no issues are found, `{:ok, warnings}` when only
  warnings are present (non-fatal), or `{:error, errors}` when errors exist.

  Runs three validation passes:
  1. **Message rules** — MSH presence, required MSH fields
  2. **Structural rules** — segment ordering, group anchors, cardinality
     (for structures with group-aware definitions), or presence-only fallback
  3. **Field rules** — required fields, max repetitions per segment

  Each error map has:
  - `:level` — `:error` or `:warning`
  - `:location` — segment identifier (e.g., `"MSH"`, `"PID"`, `"message"`)
  - `:field` — field name atom or `nil` for structural issues
  - `:message` — human-readable description

  ## Options

  - `:mode` — `:lenient` (default) or `:strict`. In lenient mode, ordering
    and cardinality issues are warnings. In strict mode, all structural
    violations are errors.
  """
  @spec validate(TypedMessage.t(), keyword()) :: :ok | {:error, [map()]} | {:ok, [map()]}
  def validate(%TypedMessage{} = msg, opts \\ []) do
    mode = Keyword.get(opts, :mode, :lenient)

    all =
      MessageRules.check(msg) ++
        structure_errors(msg, mode) ++
        Enum.flat_map(msg.segments, &FieldRules.check/1)

    errors = Enum.filter(all, &(&1.level == :error))
    warnings = Enum.filter(all, &(&1.level == :warning))

    case {errors, warnings} do
      {[], []} -> :ok
      {[], warnings} -> {:ok, warnings}
      {errors, warnings} -> {:error, errors ++ warnings}
    end
  end

  defp structure_errors(%TypedMessage{segments: segments}, mode) do
    structure_name = extract_message_structure(segments)
    segment_ids = extract_segment_ids(segments)

    # Prefer structural validation (order + groups) when definition exists
    case HL7v2.Standard.MessageStructure.get(structure_name) do
      %{} = struct_def ->
        HL7v2.Validation.Structural.validate(struct_def, segment_ids, mode: mode)

      nil ->
        # Fall back to presence-only validation
        case MessageDefinition.validate_structure(structure_name, segment_ids) do
          :ok -> []
          {:error, errors} -> errors
        end
    end
  end

  defp extract_message_structure([%HL7v2.Segment.MSH{message_type: %HL7v2.Type.MSG{} = msg} | _]) do
    msg.message_structure || infer_structure(msg.message_code, msg.trigger_event)
  end

  defp extract_message_structure(_), do: nil

  # When MSH-9.3 is absent, infer from message_code + trigger_event using canonical
  # structure resolution (e.g., "ADT" + "A28" -> "ADT_A05", not "ADT_A28").
  defp infer_structure(code, event) when is_binary(code) and is_binary(event),
    do: MessageDefinition.canonical_structure(code, event)

  defp infer_structure(code, _event) when is_binary(code), do: code
  defp infer_structure(_code, _event), do: nil

  defp extract_segment_ids(segments) do
    Enum.map(segments, fn
      %HL7v2.Segment.ZXX{segment_id: id} -> id
      %{__struct__: module} -> module.segment_id()
      {name, _fields} when is_binary(name) -> name
    end)
  end
end
