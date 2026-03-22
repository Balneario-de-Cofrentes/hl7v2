defmodule HL7v2.Validation.FieldRules do
  @moduledoc """
  Field-level validation rules for HL7v2 typed segments.

  For each typed segment struct, checks:
  - Required fields (`:r` optionality) are not nil
  - Repeating fields with bounded `max_reps` do not exceed the limit
  """

  @doc """
  Returns a list of field-level validation errors/warnings for a single segment.

  Skips validation for:
  - `HL7v2.Segment.ZXX` (site-defined, no typed fields)
  - Raw tuples `{name, fields}` (not typed)
  """
  @spec check(struct() | {binary(), list()}) :: [map()]
  def check(%HL7v2.Segment.ZXX{}), do: []
  def check({name, _fields}) when is_binary(name), do: []

  def check(%{__struct__: module} = segment) do
    location = module.segment_id()
    field_defs = module.fields()

    Enum.flat_map(field_defs, fn {_seq, name, _type, optionality, max_reps} ->
      value = Map.get(segment, name)

      required_errors(location, name, optionality, value) ++
        max_reps_warnings(location, name, max_reps, value)
    end)
  end

  defp required_errors(location, name, :r, value) do
    if semantic_blank?(value) do
      [
        %{
          level: :error,
          location: location,
          field: name,
          message: "required field #{name} is missing"
        }
      ]
    else
      []
    end
  end

  defp required_errors(_location, _name, _optionality, _value), do: []

  # A value is semantically blank if it's nil, an empty list, or a struct
  # where every field is nil (e.g., %XPN{} with all nil fields).
  defp semantic_blank?(nil), do: true
  defp semantic_blank?([]), do: true

  defp semantic_blank?(list) when is_list(list) do
    Enum.all?(list, &semantic_blank?/1)
  end

  defp semantic_blank?(struct) when is_struct(struct) do
    struct
    |> Map.from_struct()
    |> Map.values()
    |> Enum.all?(&is_nil/1)
  end

  defp semantic_blank?(_), do: false

  defp max_reps_warnings(location, name, max_reps, value)
       when is_integer(max_reps) and max_reps > 1 and is_list(value) do
    if length(value) > max_reps do
      [
        %{
          level: :warning,
          location: location,
          field: name,
          message: "field #{name} has #{length(value)} repetitions, max allowed is #{max_reps}"
        }
      ]
    else
      []
    end
  end

  defp max_reps_warnings(_location, _name, _max_reps, _value), do: []
end
