defmodule HL7v2.Access do
  @moduledoc """
  Path-based access to HL7v2 message fields.

  Provides `get/2`, `get/3`, and `fetch/2` for extracting values from typed
  messages using path strings like `"PID-5"` or `"MSH-9.1"`.

  `get/2` returns nil on any resolution failure (silent). `fetch/2` returns
  `{:ok, value}` or `{:error, reason}` for explicit error handling.

  ## Path Syntax

      "PID"          — first PID segment struct
      "PID-5"        — PID field 5 (patient_name)
      "PID-5.1"      — first component of PID-5
      "PID-3[2]"     — second repetition of PID-3
      "MSH-9.1"      — message code from MSH-9

  ## Examples

      {:ok, msg} = HL7v2.parse(text, mode: :typed)
      patient_name = HL7v2.Access.get(msg, "PID-5")
      mrn = HL7v2.Access.get(msg, "PID-3.1")

  """

  alias HL7v2.{Path, TypedMessage}

  @type path :: %{
          segment: binary(),
          field: pos_integer() | nil,
          component: pos_integer() | nil,
          repetition: pos_integer() | nil
        }

  @path_regex ~r/^([A-Z][A-Z0-9]{2})(?:-(\d+)(?:\.(\d+))?(?:\[(\d+)\])?)?$/

  @doc """
  Gets a value from a typed message using a path string or `%Path{}` struct.

  Returns `nil` if the path doesn't resolve.
  """
  @spec get(TypedMessage.t(), binary() | Path.t()) :: term()
  def get(%TypedMessage{} = msg, %Path{} = path) do
    resolve(msg, path_to_map(path))
  end

  def get(%TypedMessage{} = msg, path) when is_binary(path) do
    case parse_path(path) do
      {:ok, parsed} -> resolve(msg, parsed)
      {:error, _} -> nil
    end
  end

  @doc """
  Gets a value from a typed message with a default.
  """
  @spec get(TypedMessage.t(), binary() | Path.t(), term()) :: term()
  def get(%TypedMessage{} = msg, %Path{} = path, default) do
    case fetch(msg, path) do
      {:ok, value} -> value
      {:error, _} -> default
    end
  end

  def get(%TypedMessage{} = msg, path, default) when is_binary(path) do
    case fetch(msg, path) do
      {:ok, value} -> value
      {:error, _} -> default
    end
  end

  @doc """
  Fetches a value from a typed message, returning `{:ok, value}` or `{:error, reason}`.

  Unlike `get/2`, this function distinguishes between a nil field value and
  a resolution failure (unknown segment, invalid path, unknown field).

  Accepts both string paths and `%HL7v2.Path{}` structs.

  ## Examples

      {:ok, pid} = HL7v2.Access.fetch(msg, "PID")
      {:error, :segment_not_found} = HL7v2.Access.fetch(msg, "ZZZ")
      {:error, :invalid_path} = HL7v2.Access.fetch(msg, "not a path")
      {:error, :field_not_found} = HL7v2.Access.fetch(msg, "PID-99")

  """
  @spec fetch(TypedMessage.t(), binary() | Path.t()) :: {:ok, term()} | {:error, atom()}
  def fetch(%TypedMessage{} = msg, %Path{} = path) do
    resolve_with_error(msg, path_to_map(path))
  end

  def fetch(%TypedMessage{} = msg, path) when is_binary(path) do
    case parse_path(path) do
      {:ok, parsed} -> resolve_with_error(msg, parsed)
      {:error, _} = err -> err
    end
  end

  defp path_to_map(%Path{segment: seg, field: f, component: c, repetition: r}) do
    %{segment: seg, field: f, component: c, repetition: r}
  end

  # -- Path Parsing --

  @doc false
  @spec parse_path(binary()) :: {:ok, path()} | {:error, :invalid_path}
  def parse_path(path) do
    case Regex.run(@path_regex, path) do
      [_, segment] ->
        {:ok, %{segment: segment, field: nil, component: nil, repetition: nil}}

      [_, segment, field] ->
        {:ok, %{segment: segment, field: to_int(field), component: nil, repetition: nil}}

      [_, segment, field, component] ->
        {:ok,
         %{segment: segment, field: to_int(field), component: to_int(component), repetition: nil}}

      [_, segment, field, "", repetition] ->
        {:ok,
         %{segment: segment, field: to_int(field), component: nil, repetition: to_int(repetition)}}

      [_, segment, field, component, repetition] ->
        {:ok,
         %{
           segment: segment,
           field: to_int(field),
           component: to_int(component),
           repetition: to_int(repetition)
         }}

      nil ->
        {:error, :invalid_path}
    end
  end

  defp to_int(s), do: String.to_integer(s)

  # -- Resolution --

  defp resolve(msg, %{segment: seg_id, field: nil}) do
    find_segment(msg, seg_id)
  end

  defp resolve(msg, %{segment: seg_id} = path) do
    case find_segment(msg, seg_id) do
      nil -> nil
      segment -> resolve_field(segment, path)
    end
  end

  defp find_segment(%TypedMessage{segments: segments}, seg_id) do
    Enum.find(segments, fn
      %HL7v2.Segment.ZXX{segment_id: id} -> id == seg_id
      %{__struct__: module} -> module.segment_id() == seg_id
      {name, _fields} -> name == seg_id
      _ -> false
    end)
  end

  defp resolve_field({_name, raw_fields}, %{field: field_seq}) when is_list(raw_fields) do
    # Raw tuple segment — return the field by position (1-indexed), no type awareness
    Enum.at(raw_fields, field_seq - 1)
  end

  defp resolve_field(segment, %{field: field_seq} = path) when is_struct(segment) do
    module = segment.__struct__
    fields = module.fields()

    case Enum.find(fields, fn {seq, _, _, _, _} -> seq == field_seq end) do
      {_, field_name, _, _, max_reps} ->
        value = Map.get(segment, field_name)
        unwrap_and_select(value, max_reps, path)

      nil ->
        nil
    end
  end

  defp resolve_field(_, _), do: nil

  # Unwrap repeating fields and select component
  defp unwrap_and_select(nil, _, _), do: nil

  defp unwrap_and_select(value, max_reps, %{repetition: rep, component: comp}) do
    value = select_repetition(value, max_reps, rep)
    select_component(value, comp)
  end

  defp select_repetition(value, 1, _rep), do: value

  defp select_repetition(value, _max_reps, rep) when is_list(value) do
    if rep != nil do
      Enum.at(value, rep - 1)
    else
      List.first(value)
    end
  end

  defp select_repetition(value, _max_reps, _rep), do: value

  defp select_component(nil, _), do: nil
  defp select_component(value, nil), do: value

  defp select_component(value, comp) when is_struct(value) do
    ordered_keys =
      value.__struct__.__info__(:struct)
      |> Enum.map(& &1.field)

    case Enum.at(ordered_keys, comp - 1) do
      nil -> nil
      key -> Map.get(value, key)
    end
  end

  defp select_component(value, _comp), do: value

  # -- Error-returning resolution for fetch/2 --

  defp resolve_with_error(msg, %{segment: seg_id, field: nil}) do
    case find_segment(msg, seg_id) do
      nil -> {:error, :segment_not_found}
      seg -> {:ok, seg}
    end
  end

  defp resolve_with_error(msg, %{segment: seg_id} = path) do
    case find_segment(msg, seg_id) do
      nil -> {:error, :segment_not_found}
      segment -> resolve_field_with_error(segment, path)
    end
  end

  defp resolve_field_with_error({_name, raw_fields}, %{field: field_seq})
       when is_list(raw_fields) do
    case Enum.at(raw_fields, field_seq - 1) do
      nil -> {:ok, nil}
      value -> {:ok, value}
    end
  end

  defp resolve_field_with_error(segment, %{field: field_seq} = path)
       when is_struct(segment) do
    module = segment.__struct__
    fields = module.fields()

    case Enum.find(fields, fn {seq, _, _, _, _} -> seq == field_seq end) do
      {_, field_name, _, _, max_reps} ->
        value = Map.get(segment, field_name)
        {:ok, unwrap_and_select(value, max_reps, path)}

      nil ->
        {:error, :field_not_found}
    end
  end
end
