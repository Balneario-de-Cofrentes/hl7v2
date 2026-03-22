defmodule HL7v2.Segment do
  @moduledoc """
  Base behaviour and helpers for typed HL7v2 segments.

  Provides a `__using__` macro that generates struct, `parse/2`, and `encode/1`
  from a declarative field definition list — zero boilerplate per segment.

  ## Defining a Segment

      defmodule HL7v2.Segment.MSA do
        use HL7v2.Segment,
          id: "MSA",
          fields: [
            {1, :acknowledgment_code, HL7v2.Type.ID, :r, 1},
            {2, :message_control_id, HL7v2.Type.ST, :r, 1},
            {3, :text_message, HL7v2.Type.ST, :o, 1},
            ...
          ]
      end

  ## Field Definitions

  Each field is a tuple `{sequence, name, type, optionality, max_reps}`:

  - `sequence` — 1-based field position per HL7 spec
  - `name` — atom used as struct key
  - `type` — type module (e.g. `HL7v2.Type.ST`) or `:raw` for pass-through
  - `optionality` — `:r` (required), `:o` (optional), `:c` (conditional), `:b` (backwards-compat/withdrawn)
  - `max_reps` — `1` for non-repeating, `:unbounded` or integer for repeating
  """

  @type optionality :: :r | :o | :c | :b
  @type max_reps :: pos_integer() | :unbounded
  @type field_def :: {pos_integer(), atom(), module() | :raw, optionality(), max_reps()}

  @callback fields() :: [field_def()]
  @callback segment_id() :: binary()
  @callback parse(list(), HL7v2.Separator.t()) :: struct()
  @callback encode(struct()) :: list()

  @compile {:inline, parse_field_value: 3, encode_field_value: 3, composite_type?: 1}

  @composite_types MapSet.new([
                     HL7v2.Type.AUI,
                     HL7v2.Type.CNN,
                     HL7v2.Type.CP,
                     HL7v2.Type.CQ,
                     HL7v2.Type.CX,
                     HL7v2.Type.DLD,
                     HL7v2.Type.DLN,
                     HL7v2.Type.ELD,
                     HL7v2.Type.NDL,
                     HL7v2.Type.SPS,
                     HL7v2.Type.TQ,
                     HL7v2.Type.XCN,
                     HL7v2.Type.XPN,
                     HL7v2.Type.XAD,
                     HL7v2.Type.XTN,
                     HL7v2.Type.CE,
                     HL7v2.Type.CWE,
                     HL7v2.Type.EIP,
                     HL7v2.Type.ERL,
                     HL7v2.Type.FC,
                     HL7v2.Type.HD,
                     HL7v2.Type.JCC,
                     HL7v2.Type.MO,
                     HL7v2.Type.MOC,
                     HL7v2.Type.PL,
                     HL7v2.Type.PRL,
                     HL7v2.Type.EI,
                     HL7v2.Type.MSG,
                     HL7v2.Type.PT,
                     HL7v2.Type.VID,
                     HL7v2.Type.CNE,
                     HL7v2.Type.XON,
                     HL7v2.Type.FN,
                     HL7v2.Type.SAD,
                     HL7v2.Type.DR,
                     HL7v2.Type.TS,
                     HL7v2.Type.NR
                   ])

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour HL7v2.Segment

      @segment_id Keyword.fetch!(opts, :id)
      @segment_fields Keyword.fetch!(opts, :fields)

      @struct_keys Enum.map(@segment_fields, fn {_seq, name, _type, _opt, _reps} -> name end)
      defstruct @struct_keys ++ [extra_fields: []]

      @type t :: %__MODULE__{}

      @impl HL7v2.Segment
      def fields, do: @segment_fields

      @impl HL7v2.Segment
      def segment_id, do: @segment_id

      @impl HL7v2.Segment
      @spec parse(list(), HL7v2.Separator.t()) :: t()
      def parse(raw_fields, separators \\ HL7v2.Separator.default()) do
        HL7v2.Segment.do_parse(__MODULE__, @segment_fields, raw_fields, separators)
      end

      @impl HL7v2.Segment
      @spec encode(t()) :: list()
      def encode(%__MODULE__{} = segment) do
        HL7v2.Segment.do_encode(segment, @segment_fields)
      end

      defoverridable parse: 1, parse: 2, encode: 1
    end
  end

  # --- Runtime Parse/Encode Helpers ---

  @doc false
  @spec do_parse(module(), [field_def()], list(), HL7v2.Separator.t()) :: struct()
  def do_parse(module, field_defs, raw_fields, separators \\ HL7v2.Separator.default()) do
    sep = <<separators.sub_component>>

    ensure_sub_component_separator(sep, fn ->
      attrs =
        Enum.map(field_defs, fn {seq, name, type, _opt, max_reps} ->
          raw = Enum.at(raw_fields, seq - 1)
          {name, parse_field_value(raw, type, max_reps)}
        end)

      max_seq = max_declared_seq(field_defs)
      extra = Enum.drop(raw_fields, max_seq)

      struct(module, [{:extra_fields, extra} | attrs])
    end)
  end

  @doc false
  @spec do_encode(struct(), [field_def()], HL7v2.Separator.t()) :: list()
  def do_encode(segment, field_defs, separators \\ HL7v2.Separator.default()) do
    sep = <<separators.sub_component>>

    ensure_sub_component_separator(sep, fn ->
      declared =
        Enum.map(field_defs, fn {_seq, name, type, _opt, max_reps} ->
          value = Map.get(segment, name)
          encode_field_value(value, type, max_reps)
        end)

      extra = Map.get(segment, :extra_fields) || []
      (declared ++ extra) |> trim_trailing()
    end)
  end

  # --- Field-Level Parse ---

  @doc false
  @spec parse_field_value(term(), module() | :raw, max_reps()) :: term()
  def parse_field_value(nil, _type, _max_reps), do: nil
  def parse_field_value("", _type, _max_reps), do: nil
  def parse_field_value(raw, :raw, _max_reps), do: raw

  def parse_field_value(raw, type, 1) do
    parse_single(raw, type)
  end

  def parse_field_value(raw, type, _max_reps) do
    parse_repeating(raw, type)
  end

  defp parse_single(raw, type) do
    if composite_type?(type) do
      components = if is_binary(raw), do: [raw], else: raw
      type.parse(components)
    else
      case raw do
        # Primitive with extra components (e.g., "M^EXTRA" on an IS field).
        # Non-conformant input — preserve the raw component list for lossless
        # round-trip. The encoder emits lists as component-separated values.
        [_first | rest] = list when rest != [] ->
          list

        [first] ->
          type.parse(first || "")

        value when is_binary(value) ->
          type.parse(value)

        _ ->
          type.parse("")
      end
    end
  end

  defp parse_repeating(raw, type) when is_binary(raw) do
    [parse_single(raw, type)]
  end

  defp parse_repeating(raw, type) when is_list(raw) do
    if composite_type?(type) do
      parse_repeating_composite(raw, type)
    else
      parse_repeating_primitive(raw, type)
    end
  end

  # Multiple repetitions when each element is already a list of components;
  # otherwise a single composite value (its components, not repeated).
  defp parse_repeating_composite(raw, type) do
    if all_lists?(raw) do
      Enum.map(raw, &type.parse/1)
    else
      [type.parse(raw)]
    end
  end

  # Repeated primitive -- each element is a string value.
  defp parse_repeating_primitive(raw, type) do
    Enum.map(raw, fn
      v when is_binary(v) -> type.parse(v)
      [_first | rest] = list when rest != [] -> list
      [first] -> type.parse(first || "")
      _ -> nil
    end)
  end

  # --- Field-Level Encode ---

  @doc false
  @spec encode_field_value(term(), module() | :raw, max_reps()) :: term()
  def encode_field_value(nil, _type, _max_reps), do: ""
  def encode_field_value(value, :raw, _max_reps), do: value || ""

  def encode_field_value(value, type, 1) do
    encode_single(value, type)
  end

  def encode_field_value(values, type, _max_reps) when is_list(values) do
    case values do
      [] ->
        ""

      [single] ->
        # Single repetition — encode directly (no repetition wrapper needed)
        encode_single(single, type)

      multiple ->
        # Multiple repetitions
        Enum.map(multiple, fn v -> wrap_for_repetition(encode_single(v, type)) end)
    end
  end

  # Single value in a repeating field slot — encode directly
  def encode_field_value(value, type, _max_reps) do
    encode_single(value, type)
  end

  defp encode_single(nil, _type), do: ""

  # Primitive fields with extra components preserved as raw lists (non-conformant input).
  # Emit as component list for the encoder to rejoin with ^.
  defp encode_single(value, _type) when is_list(value), do: value

  defp encode_single(value, type), do: type.encode(value)

  # Ensure repeated values produce list-of-lists for the raw encoder.
  # Composite types already return lists from encode. Primitive types return binaries,
  # which need wrapping in a list so the encoder treats them as repetitions.
  defp wrap_for_repetition(value) when is_list(value), do: value
  defp wrap_for_repetition(value) when is_binary(value), do: [value]

  # --- Helpers ---

  @doc false
  @spec composite_type?(module()) :: boolean()
  def composite_type?(type), do: MapSet.member?(@composite_types, type)

  defp all_lists?(list), do: Enum.all?(list, &is_list/1)

  @doc false
  @spec trim_trailing(list()) :: list()
  def trim_trailing(list) do
    list
    |> Enum.reverse()
    |> Enum.drop_while(&empty_field?/1)
    |> Enum.reverse()
  end

  defp empty_field?(""), do: true
  defp empty_field?(nil), do: true
  defp empty_field?([]), do: true
  defp empty_field?(_), do: false

  # Sets the sub-component separator only if no separator context is already
  # active (i.e., a caller like TypedParser.to_raw has not already set it).
  # This prevents do_parse/do_encode from overriding an outer separator context.
  defp ensure_sub_component_separator(sep, fun) do
    if Process.get(:hl7v2_sub_component_sep) do
      # Separator already set by an outer context — don't override
      fun.()
    else
      HL7v2.Type.with_sub_component_separator(sep, fun)
    end
  end

  @doc false
  @spec max_declared_seq([field_def()]) :: non_neg_integer()
  def max_declared_seq([]), do: 0

  def max_declared_seq(field_defs) do
    field_defs
    |> Enum.map(fn {seq, _, _, _, _} -> seq end)
    |> Enum.max()
  end
end
