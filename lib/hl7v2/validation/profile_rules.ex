defmodule HL7v2.Validation.ProfileRules do
  @moduledoc """
  Evaluates a `HL7v2.Profile` against a typed message and returns validation
  errors. Called from `HL7v2.Validation.validate/2` when a `:profile` option
  is provided.

  Profile errors include `:rule` (which rule type fired) and `:profile`
  (profile name) fields in addition to the standard
  `:level/:location/:field/:message` shape used by the rest of the validation
  stack.

  ## Rule Evaluation Order

  For each profile, the following checks run in order and all errors from all
  checks are collected (short-circuiting is intentionally avoided so integrators
  see a complete diagnostic in one pass):

  1. `require_segment` — every segment in `profile.required_segments` must appear
  2. `forbid_segment` — no segment in `profile.forbidden_segments` may appear
  3. `require_field`  — every `{seg_id, field_seq}` must be populated when its
     segment is present; missing segment is also an error
  4. `forbid_field` — every `{seg_id, field_seq}` in `profile.forbidden_fields`
     must be blank or absent
  5. `require_value` — a declarative equality or membership pin on a field
     (from `Profile.require_value/5` or `Profile.require_value_in/5`)
  6. `require_component` — a declarative component/subcomponent pin on a
     composite field (from `Profile.require_component/5`)
  7. `require_cardinality` — segment occurrence counts must fall within `{min, max}`
  8. `value_constraint` — custom predicate on a field value (only when field present)
  9. `custom_rule` — arbitrary function returning error maps

  Custom rule errors are tagged with `:rule` (the rule name) and `:profile`
  (the profile name) if the rule did not set them. If a custom rule raises,
  a synthetic `:custom_rule_exception` error is emitted — exceptions are
  never silently swallowed.

  ## Applicability

  A profile is applied only when its `:message_type` tuple matches the
  typed message's code/event AND (when declared) its `:version` matches
  the version in MSH-12. A profile with nil `:message_type` matches any
  type; a profile with nil `:version` matches any version.
  """

  alias HL7v2.{Profile, TypedMessage}

  @type error :: %{
          level: :error | :warning,
          location: String.t(),
          field: atom() | nil,
          message: String.t(),
          rule: atom(),
          profile: String.t()
        }

  @doc """
  Evaluates a profile against a typed message.

  Returns `[]` if the message satisfies all profile rules, or a list of
  error maps describing each violation.

  If the profile declares a `:message_type` and it doesn't match the typed
  message's type, the profile is considered not applicable and `[]` is
  returned — it is the caller's responsibility to decide whether a
  non-matching profile is itself an error.
  """
  @spec check(TypedMessage.t(), Profile.t()) :: [error()]
  def check(%TypedMessage{} = msg, %Profile{} = profile) do
    with true <- Profile.applies_to?(profile, extract_code_event(msg.type)),
         true <- version_matches?(profile, msg) do
      []
      |> check_required_segments(msg, profile)
      |> check_forbidden_segments(msg, profile)
      |> check_required_fields(msg, profile)
      |> check_forbidden_fields(msg, profile)
      |> check_required_values(msg, profile)
      |> check_required_components(msg, profile)
      |> check_cardinality(msg, profile)
      |> check_value_constraints(msg, profile)
      |> check_custom_rules(msg, profile)
      |> Enum.reverse()
    else
      _ -> []
    end
  end

  # TypedMessage.type is either {code, event} or {code, event, structure}.
  # Profile.applies_to?/2 compares against the 2-tuple form.
  defp extract_code_event({code, event}), do: {code, event}
  defp extract_code_event({code, event, _structure}), do: {code, event}
  defp extract_code_event(_), do: nil

  # A profile with nil :version matches any message version. Otherwise the
  # first component of MSH-12 (the VID version_id string) must equal the
  # profile's declared version. If MSH or MSH-12 can't be located, the
  # profile does not apply (avoids false positives against malformed input).
  defp version_matches?(%Profile{version: nil}, _msg), do: true

  defp version_matches?(%Profile{version: version}, %TypedMessage{segments: segments}) do
    case find_msh_version(segments) do
      {:ok, ^version} -> true
      _ -> false
    end
  end

  defp find_msh_version(segments) do
    case Enum.find(segments, &match?(%HL7v2.Segment.MSH{}, &1)) do
      %HL7v2.Segment.MSH{version_id: %HL7v2.Type.VID{version_id: v}} when is_binary(v) ->
        {:ok, v}

      _ ->
        :error
    end
  end

  # --- require_segment ---

  defp check_required_segments(errors, msg, profile) do
    actual = MapSet.new(segment_ids(msg.segments))
    missing = MapSet.difference(profile.required_segments, actual)

    Enum.reduce(missing, errors, fn seg_id, acc ->
      [
        profile_error(
          profile,
          :require_segment,
          seg_id,
          nil,
          "profile requires segment #{seg_id} to be present"
        )
        | acc
      ]
    end)
  end

  # --- forbid_segment ---

  defp check_forbidden_segments(errors, msg, profile) do
    actual = MapSet.new(segment_ids(msg.segments))
    found = MapSet.intersection(profile.forbidden_segments, actual)

    Enum.reduce(found, errors, fn seg_id, acc ->
      [
        profile_error(
          profile,
          :forbid_segment,
          seg_id,
          nil,
          "profile forbids segment #{seg_id} but it is present"
        )
        | acc
      ]
    end)
  end

  # --- require_field ---

  defp check_required_fields(errors, msg, profile) do
    Enum.reduce(profile.required_fields, errors, fn {{seg_id, field_seq}, _}, acc ->
      case find_segment_field(msg.segments, seg_id, field_seq) do
        {:ok, value, field_name} ->
          if blank?(value) do
            [
              profile_error(
                profile,
                :require_field,
                seg_id,
                field_name,
                "profile requires #{seg_id}-#{field_seq} to be populated"
              )
              | acc
            ]
          else
            acc
          end

        :segment_missing ->
          [
            profile_error(
              profile,
              :require_field,
              seg_id,
              nil,
              "profile requires #{seg_id}-#{field_seq} but segment #{seg_id} is missing"
            )
            | acc
          ]

        :field_not_defined ->
          [
            profile_error(
              profile,
              :require_field,
              seg_id,
              nil,
              "profile requires #{seg_id}-#{field_seq} but the segment does not define that field"
            )
            | acc
          ]
      end
    end)
  end

  # --- forbid_field ---

  defp check_forbidden_fields(errors, msg, profile) do
    Enum.reduce(profile.forbidden_fields, errors, fn {seg_id, field_seq}, acc ->
      case find_segment_field(msg.segments, seg_id, field_seq) do
        {:ok, value, field_name} ->
          if blank?(value) do
            acc
          else
            [
              profile_error(
                profile,
                :forbid_field,
                seg_id,
                field_name,
                "profile forbids #{seg_id}-#{field_seq} but it is populated"
              )
              | acc
            ]
          end

        :segment_missing ->
          acc

        :field_not_defined ->
          acc
      end
    end)
  end

  # --- require_value / require_value_in ---

  defp check_required_values(errors, msg, profile) do
    Enum.reduce(profile.required_values, errors, fn {{seg_id, field_seq}, spec}, acc ->
      case find_segment_field(msg.segments, seg_id, field_seq) do
        {:ok, value, field_name} ->
          apply_value_spec(acc, profile, seg_id, field_seq, field_name, value, spec)

        :segment_missing ->
          acc

        :field_not_defined ->
          acc
      end
    end)
  end

  defp apply_value_spec(acc, profile, seg_id, field_seq, field_name, value, {:eq, expected, opts}) do
    actual = apply_accessor(value, opts)

    cond do
      blank?(actual) ->
        [
          profile_error(
            profile,
            :require_value,
            seg_id,
            field_name,
            "profile requires #{seg_id}-#{field_seq} to equal #{inspect(expected)}, " <>
              "but it is blank"
          )
          | acc
        ]

      actual == expected ->
        acc

      true ->
        [
          profile_error(
            profile,
            :require_value,
            seg_id,
            field_name,
            "profile requires #{seg_id}-#{field_seq} to equal #{inspect(expected)}, " <>
              "got #{inspect(actual)}"
          )
          | acc
        ]
    end
  end

  defp apply_value_spec(
         acc,
         profile,
         seg_id,
         field_seq,
         field_name,
         value,
         {:in, allowed, opts}
       ) do
    actual = apply_accessor(value, opts)

    cond do
      blank?(actual) ->
        [
          profile_error(
            profile,
            :require_value,
            seg_id,
            field_name,
            "profile requires #{seg_id}-#{field_seq} to be one of #{inspect(allowed)}, " <>
              "but it is blank"
          )
          | acc
        ]

      actual in allowed ->
        acc

      true ->
        [
          profile_error(
            profile,
            :require_value,
            seg_id,
            field_name,
            "profile requires #{seg_id}-#{field_seq} to be one of #{inspect(allowed)}, " <>
              "got #{inspect(actual)}"
          )
          | acc
        ]
    end
  end

  defp apply_accessor(value, opts) do
    case Keyword.get(opts, :accessor) do
      fun when is_function(fun, 1) -> apply_accessor_safe(fun, value)
      nil -> value
    end
  end

  defp apply_accessor_safe(_fun, nil), do: nil

  defp apply_accessor_safe(fun, value) do
    fun.(value)
  rescue
    _ -> nil
  end

  # --- require_component ---

  defp check_required_components(errors, msg, profile) do
    Enum.reduce(profile.required_components, errors, fn entry, acc ->
      check_component_entry(acc, msg, profile, entry)
    end)
  end

  defp check_component_entry(errors, msg, profile, {seg_id, field_seq, component, opts}) do
    each_repetition? = Keyword.get(opts, :each_repetition, false)
    subcomponent = Keyword.get(opts, :subcomponent)
    fixed_repetition = Keyword.get(opts, :repetition, 1)

    case find_segment_field(msg.segments, seg_id, field_seq) do
      {:ok, nil, _field_name} ->
        errors

      {:ok, value, field_name} ->
        occurrences = normalize_occurrences(value, each_repetition?, fixed_repetition)

        Enum.reduce(occurrences, errors, fn {rep_struct, rep_idx}, acc ->
          check_component_value(
            acc,
            profile,
            seg_id,
            field_seq,
            field_name,
            rep_struct,
            rep_idx,
            component,
            subcomponent
          )
        end)

      _ ->
        errors
    end
  end

  # Normalize field value into a list of {struct, repetition_index}
  # tuples for uniform iteration.
  defp normalize_occurrences(value, true = _each_repetition?, _fixed) when is_list(value) do
    value
    |> Enum.with_index(1)
    |> Enum.map(fn {v, i} -> {v, i} end)
  end

  defp normalize_occurrences(value, true = _each_repetition?, _fixed), do: [{value, 1}]

  defp normalize_occurrences(value, false, fixed_repetition) when is_list(value) do
    case Enum.at(value, fixed_repetition - 1) do
      nil -> []
      v -> [{v, fixed_repetition}]
    end
  end

  defp normalize_occurrences(value, false, _fixed_repetition), do: [{value, 1}]

  defp check_component_value(
         errors,
         profile,
         seg_id,
         field_seq,
         field_name,
         rep_struct,
         rep_idx,
         component,
         subcomponent
       ) do
    case HL7v2.Profile.ComponentAccess.component_at(rep_struct, component) do
      {:ok, component_value} ->
        check_subcomponent(
          errors,
          profile,
          seg_id,
          field_seq,
          field_name,
          rep_idx,
          component,
          component_value,
          subcomponent
        )

      {:error, {:unknown_composite_type, mod}} ->
        [
          profile_error(
            profile,
            :require_component,
            seg_id,
            field_name,
            "profile requires #{seg_id}-#{field_seq} component access for " <>
              "#{inspect(mod)}, but that type is not registered in " <>
              "HL7v2.Profile.ComponentAccess"
          )
          | errors
        ]

      {:error, reason} ->
        [
          profile_error(
            profile,
            :require_component,
            seg_id,
            field_name,
            "profile requires #{seg_id}-#{field_seq} component #{component} but " <>
              "access failed: #{inspect(reason)}"
          )
          | errors
        ]
    end
  end

  defp check_subcomponent(
         errors,
         profile,
         seg_id,
         field_seq,
         field_name,
         rep_idx,
         component,
         component_value,
         nil = _subcomponent
       ) do
    if blank?(component_value) do
      [
        profile_error(
          profile,
          :require_component,
          seg_id,
          field_name,
          "profile requires #{seg_id}-#{field_seq}[#{rep_idx}].#{component} to be populated"
        )
        | errors
      ]
    else
      errors
    end
  end

  defp check_subcomponent(
         errors,
         profile,
         seg_id,
         field_seq,
         field_name,
         rep_idx,
         component,
         component_value,
         subcomponent
       )
       when is_integer(subcomponent) and subcomponent > 0 do
    case HL7v2.Profile.ComponentAccess.component_at(component_value, subcomponent) do
      {:ok, sub_value} ->
        if blank?(sub_value) do
          [
            profile_error(
              profile,
              :require_component,
              seg_id,
              field_name,
              "profile requires #{seg_id}-#{field_seq}[#{rep_idx}].#{component}.#{subcomponent} to be populated"
            )
            | errors
          ]
        else
          errors
        end

      {:error, _reason} ->
        [
          profile_error(
            profile,
            :require_component,
            seg_id,
            field_name,
            "profile requires #{seg_id}-#{field_seq}[#{rep_idx}].#{component}.#{subcomponent} to be populated"
          )
          | errors
        ]
    end
  end

  # --- require_cardinality ---

  defp check_cardinality(errors, msg, profile) do
    counts =
      msg.segments
      |> segment_ids()
      |> Enum.frequencies()

    Enum.reduce(profile.cardinality_constraints, errors, fn {seg_id, {min, max}}, acc ->
      count = Map.get(counts, seg_id, 0)

      cond do
        count < min ->
          [
            profile_error(
              profile,
              :require_cardinality,
              seg_id,
              nil,
              "profile requires at least #{min} #{seg_id} segment(s), found #{count}"
            )
            | acc
          ]

        max != :unbounded and count > max ->
          [
            profile_error(
              profile,
              :require_cardinality,
              seg_id,
              nil,
              "profile allows at most #{max} #{seg_id} segment(s), found #{count}"
            )
            | acc
          ]

        true ->
          acc
      end
    end)
  end

  # --- value_constraint ---

  defp check_value_constraints(errors, msg, profile) do
    Enum.reduce(profile.value_constraints, errors, fn {{seg_id, field_seq}, fun}, acc ->
      case find_segment_field(msg.segments, seg_id, field_seq) do
        {:ok, value, field_name} ->
          case safe_apply_constraint(fun, value) do
            true ->
              acc

            false ->
              [
                profile_error(
                  profile,
                  :value_constraint,
                  seg_id,
                  field_name,
                  "profile value constraint failed for #{seg_id}-#{field_seq}"
                )
                | acc
              ]

            {:error, reason} ->
              [
                profile_error(
                  profile,
                  :value_constraint,
                  seg_id,
                  field_name,
                  "profile value constraint failed for #{seg_id}-#{field_seq}: #{reason}"
                )
                | acc
              ]

            other ->
              [
                profile_error(
                  profile,
                  :value_constraint,
                  seg_id,
                  field_name,
                  "profile value constraint returned an unexpected value: #{inspect(other)}"
                )
                | acc
              ]
          end

        :segment_missing ->
          # Value constraints apply only when the field is present.
          acc

        :field_not_defined ->
          acc
      end
    end)
  end

  # --- custom_rule ---

  defp check_custom_rules(errors, msg, profile) do
    Enum.reduce(profile.custom_rules, errors, fn {rule_name, fun}, acc ->
      case safe_apply_rule(fun, msg) do
        {:ok, rule_errors} when is_list(rule_errors) ->
          tagged =
            Enum.map(rule_errors, fn err ->
              err
              |> Map.put_new(:rule, rule_name)
              |> Map.put_new(:profile, profile.name)
              |> Map.put_new(:level, :error)
              |> Map.put_new(:location, "")
              |> Map.put_new(:field, nil)
              |> Map.put_new(:message, "custom profile rule failed")
            end)

          Enum.reduce(tagged, acc, fn err, inner -> [err | inner] end)

        {:exception, message} ->
          [
            profile_error(
              profile,
              :custom_rule_exception,
              "",
              nil,
              "custom rule #{inspect(rule_name)} raised: #{message}"
            )
            | acc
          ]

        _ ->
          acc
      end
    end)
  end

  # --- helpers: segment identity ---

  @spec segment_ids([struct() | {binary(), list()}]) :: [binary()]
  defp segment_ids(segments), do: Enum.map(segments, &segment_id/1)

  # ZXX stores its id as a struct field (not a behaviour callback) because its
  # segment_id is dynamic per instance.
  defp segment_id(%HL7v2.Segment.ZXX{segment_id: id}), do: id
  defp segment_id(%{__struct__: module}), do: safe_segment_id(module)
  defp segment_id({name, _fields}) when is_binary(name), do: name
  defp segment_id(_), do: nil

  defp safe_segment_id(module) do
    module.segment_id()
  rescue
    _ -> nil
  end

  # --- helpers: field lookup ---

  # Locates a field by segment id and 1-based field sequence. Returns:
  #
  # - `{:ok, value, field_name}` when the segment is present and declares the field
  # - `:segment_missing` when no segment with `seg_id` exists
  # - `:field_not_defined` when the segment exists but the sequence is unknown
  @spec find_segment_field([struct() | {binary(), list()}], binary(), pos_integer()) ::
          {:ok, term(), atom() | nil} | :segment_missing | :field_not_defined
  defp find_segment_field(segments, seg_id, field_seq) do
    case Enum.find(segments, fn seg -> segment_id(seg) == seg_id end) do
      nil ->
        :segment_missing

      %HL7v2.Segment.ZXX{} ->
        # ZXX segments have no declarative field schema — treat as undefined.
        :field_not_defined

      %{__struct__: module} = seg ->
        case Enum.find(module.fields(), fn {seq, _, _, _, _} -> seq == field_seq end) do
          {_seq, name, _type, _opt, _reps} -> {:ok, Map.get(seg, name), name}
          nil -> :field_not_defined
        end

      {_name, _fields} ->
        # Untyped fallback tuple — no schema to resolve field sequences against.
        :field_not_defined
    end
  end

  # --- helpers: blank detection ---

  defp blank?(nil), do: true
  defp blank?(""), do: true
  defp blank?([]), do: true
  defp blank?(list) when is_list(list), do: Enum.all?(list, &blank?/1)

  defp blank?(%_{} = struct) do
    struct
    |> Map.from_struct()
    |> Map.values()
    |> Enum.all?(&blank?/1)
  end

  defp blank?(_), do: false

  # --- helpers: safe function application ---

  defp safe_apply_constraint(fun, value) do
    fun.(value)
  rescue
    e -> {:error, Exception.message(e)}
  end

  defp safe_apply_rule(fun, msg) do
    {:ok, fun.(msg)}
  rescue
    e -> {:exception, Exception.message(e)}
  end

  # --- helpers: error construction ---

  defp profile_error(%Profile{name: name}, rule, location, field, message) do
    %{
      level: :error,
      location: location,
      field: field,
      message: message,
      rule: rule,
      profile: name
    }
  end
end
