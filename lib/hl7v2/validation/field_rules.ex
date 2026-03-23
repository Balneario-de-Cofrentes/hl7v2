defmodule HL7v2.Validation.FieldRules do
  @moduledoc """
  Field-level validation rules for HL7v2 typed segments.

  For each typed segment struct, checks:
  - Required fields (`:r` optionality) are not nil
  - Repeating fields with bounded `max_reps` do not exceed the limit
  - Coded fields against HL7-defined tables (opt-in via `validate_tables: true`)
  """

  alias HL7v2.Standard.Tables

  # Mapping of {segment_id, field_name} to HL7 table ID.
  # Only fields where we know the canonical table binding are listed.
  @table_bindings %{
    {"MSH", :message_type} => {76, :message_code},
    {"MSH", :processing_id} => {103, :processing_id},
    {"MSH", :version_id} => {104, :version_id},
    {"MSH", :accept_acknowledgment_type} => {155, :scalar},
    {"MSH", :application_acknowledgment_type} => {155, :scalar},
    {"PID", :administrative_sex} => {1, :scalar},
    {"PV1", :patient_class} => {4, :scalar},
    {"PV1", :admission_type} => {7, :scalar},
    {"MSA", :acknowledgment_code} => {8, :scalar},
    {"OBX", :observation_result_status} => {85, :scalar},
    {"OBX", :value_type} => {125, :scalar}
  }

  @doc """
  Returns a list of field-level validation errors/warnings for a single segment.

  Skips validation for:
  - `HL7v2.Segment.ZXX` (site-defined, no typed fields)
  - Raw tuples `{name, fields}` (not typed)

  ## Options

  - `:validate_tables` -- when `true`, checks coded fields against HL7 tables.
    Defaults to `false`.
  """
  @spec check(struct() | {binary(), list()}, keyword()) :: [map()]
  def check(segment, opts \\ [])

  def check(%HL7v2.Segment.ZXX{}, _opts), do: []
  def check({name, _fields}, _opts) when is_binary(name), do: []

  def check(%{__struct__: module} = segment, opts) do
    location = module.segment_id()
    field_defs = module.fields()
    validate_tables? = Keyword.get(opts, :validate_tables, false)
    mode = Keyword.get(opts, :mode, :lenient)

    Enum.flat_map(field_defs, fn {_seq, name, _type, optionality, max_reps} ->
      value = Map.get(segment, name)

      required_errors(location, name, optionality, value) ++
        max_reps_errors(location, name, max_reps, value, mode) ++
        table_errors(location, name, value, validate_tables?)
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

  defp max_reps_errors(location, name, max_reps, value, mode)
       when is_integer(max_reps) and max_reps > 1 and is_list(value) do
    if length(value) > max_reps do
      level = if mode == :strict, do: :error, else: :warning

      [
        %{
          level: level,
          location: location,
          field: name,
          message: "field #{name} has #{length(value)} repetitions, max allowed is #{max_reps}"
        }
      ]
    else
      []
    end
  end

  defp max_reps_errors(_location, _name, _max_reps, _value, _mode), do: []

  # Table validation — only runs when validate_tables? is true and the field
  # has a known table binding. Returns errors for invalid coded values.
  defp table_errors(_location, _name, _value, false), do: []
  defp table_errors(_location, _name, nil, _validate?), do: []

  defp table_errors(location, name, value, true) do
    case Map.get(@table_bindings, {location, name}) do
      nil ->
        []

      {table_id, :scalar} ->
        validate_scalar(location, name, table_id, value)

      {table_id, subfield} ->
        validate_subfield(location, name, table_id, subfield, value)
    end
  end

  defp validate_scalar(_location, _name, _table_id, value) when not is_binary(value), do: []

  defp validate_scalar(location, name, table_id, value) do
    case Tables.validate(table_id, value) do
      :ok -> []
      {:error, msg} -> [table_error(location, name, msg)]
    end
  end

  defp validate_subfield(_location, _name, _table_id, _subfield, value)
       when not is_struct(value),
       do: []

  defp validate_subfield(location, name, table_id, subfield, value) do
    code = Map.get(value, subfield)

    if is_binary(code) do
      case Tables.validate(table_id, code) do
        :ok -> []
        {:error, msg} -> [table_error(location, name, msg)]
      end
    else
      []
    end
  end

  defp table_error(location, field, message) do
    %{level: :error, location: location, field: field, message: message}
  end
end
