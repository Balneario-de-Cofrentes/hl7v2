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
     for all 186 official v2.5.1 message structures. Unsupported structures produce a
     warning in lenient mode or an error in strict mode.
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
  - `:validate_tables` — `true` to check coded fields against HL7-defined
    tables. Defaults to `false`.
  - `:version` — explicit HL7 version override (e.g. `"2.7"`). When provided,
    version-specific rules (B-field exemptions, etc.) use this value instead
    of the one extracted from MSH-12. Invalid or unrecognized versions fall
    back to the MSH-12 value. Defaults to `nil` (read MSH-12).
  """
  @spec validate(TypedMessage.t(), keyword()) :: :ok | {:error, [map()]} | {:ok, [map()]}
  def validate(%TypedMessage{} = msg, opts \\ []) do
    mode = Keyword.get(opts, :mode, :lenient)
    context = merge_version_override(extract_trigger_context(msg.segments), opts)

    field_opts =
      Keyword.take(opts, [:validate_tables, :mode])
      |> Keyword.put(:mode, mode)
      |> Keyword.put(:context, context)

    all =
      MessageRules.check(msg) ++
        structure_errors(msg, mode) ++
        Enum.flat_map(msg.segments, &FieldRules.check(&1, field_opts))

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
        # No group-aware structure definition exists.
        # In strict mode, unsupported structures are errors.
        case MessageDefinition.validate_structure(structure_name, segment_ids) do
          :ok ->
            []

          {:error, results} ->
            if mode == :strict do
              Enum.map(results, fn
                %{level: :warning} = r -> %{r | level: :error}
                r -> r
              end)
            else
              results
            end
        end
    end
  end

  defp extract_message_structure([%HL7v2.Segment.MSH{message_type: %HL7v2.Type.MSG{} = msg} | _]) do
    # Always canonicalize via message_code + trigger_event first. MSH-9.3 may
    # carry a non-canonical alias (e.g., "SIU_S14" instead of "SIU_S12") that
    # won't match the structure registry. Fall back to MSH-9.3 only when
    # canonical resolution yields a default "CODE_EVENT" that isn't registered.
    canonical = canonicalize_structure(msg.message_code, msg.trigger_event)

    cond do
      canonical != nil -> canonical
      msg.message_structure != nil -> msg.message_structure
      true -> nil
    end
  end

  defp extract_message_structure(_), do: nil

  defp canonicalize_structure(code, event) when is_binary(code) and is_binary(event) do
    resolved = MessageDefinition.canonical_structure(code, event)

    cond do
      # Canonical resolution found a registered structure
      HL7v2.Standard.MessageStructure.get(resolved) != nil ->
        resolved

      # Fallback: the bare message_code is itself a registered structure.
      # Handles cases like ACK^A01^ACK_A01 — ACK_A01 isn't registered, but
      # ACK is. Also covers ACK^A02^ACK_A02, ACK^A08^ACK_A08, etc.
      HL7v2.Standard.MessageStructure.get(code) != nil ->
        code

      true ->
        nil
    end
  end

  defp canonicalize_structure(_code, _event), do: nil

  defp extract_trigger_context(
         [%HL7v2.Segment.MSH{message_type: %HL7v2.Type.MSG{} = msg} | _] = segments
       ) do
    %{
      trigger_event: msg.trigger_event,
      message_code: msg.message_code,
      version: extract_version(segments)
    }
  end

  defp extract_trigger_context(_), do: %{}

  # Applies an explicit `:version` override from caller options on top of the
  # context extracted from MSH-12. When the caller passes a recognizable version
  # string, it takes precedence. Unrecognized overrides fall through to the
  # value already in `context` (typically the MSH-12 value) so callers can't
  # accidentally disable version-aware rules by passing garbage.
  defp merge_version_override(context, opts) do
    case Keyword.get(opts, :version) do
      nil ->
        context

      raw ->
        case HL7v2.Standard.Version.normalize(raw) do
          nil -> context
          normalized -> Map.put(context, :version, normalized)
        end
    end
  end

  # Extracts the HL7 version (MSH-12.1) from the first segment of a message.
  # Returns a normalized canonical version string (e.g., "2.5.1", "2.7") or
  # `nil` when the version cannot be determined.
  defp extract_version([%HL7v2.Segment.MSH{version_id: %HL7v2.Type.VID{version_id: raw}} | _])
       when is_binary(raw) do
    HL7v2.Standard.Version.normalize(raw)
  end

  defp extract_version(_), do: nil

  defp extract_segment_ids(segments) do
    Enum.map(segments, fn
      %HL7v2.Segment.ZXX{segment_id: id} -> id
      %{__struct__: module} -> module.segment_id()
      {name, _fields} when is_binary(name) -> name
    end)
  end
end
