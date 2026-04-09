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
  4. `require_cardinality` — segment occurrence counts must fall within `{min, max}`
  5. `value_constraint` — custom predicate on a field value (only when field present)
  6. `custom_rule` — arbitrary function returning error maps

  Custom rule errors are tagged with `:rule` (the rule name) and `:profile`
  (the profile name) if the rule did not set them.
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
    if Profile.applies_to?(profile, extract_code_event(msg.type)) do
      []
      |> check_required_segments(msg, profile)
      |> check_forbidden_segments(msg, profile)
      |> check_required_fields(msg, profile)
      |> check_cardinality(msg, profile)
      |> check_value_constraints(msg, profile)
      |> check_custom_rules(msg, profile)
      |> Enum.reverse()
    else
      []
    end
  end

  # TypedMessage.type is either {code, event} or {code, event, structure}.
  # Profile.applies_to?/2 compares against the 2-tuple form.
  defp extract_code_event({code, event}), do: {code, event}
  defp extract_code_event({code, event, _structure}), do: {code, event}
  defp extract_code_event(_), do: nil

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
        rule_errors when is_list(rule_errors) ->
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
    fun.(msg)
  rescue
    _ -> []
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
