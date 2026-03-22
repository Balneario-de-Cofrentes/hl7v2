defmodule HL7v2.Type do
  @moduledoc """
  Base behaviour for HL7v2 data types.

  Every data type module (primitive and composite) implements this behaviour,
  providing `parse/1` and `encode/1` for converting between wire-format
  representations and typed Elixir values.

  Primitive types (ST, NM, DT, etc.) work with binaries.
  Composite types (CX, XPN, HD, etc.) work with lists of component strings
  and return/accept structs.

  ## Sub-Component Separator

  By default, sub-component fields are split/joined with `&`. When a message
  declares a non-default sub-component separator (e.g., `$` in MSH-2 `^~\\$`),
  call `with_sub_component_separator/2` to set it for the duration of a
  parse or encode operation. Composite types read the active separator via
  `sub_component_separator/0`.
  """

  alias __MODULE__.{TS, DTM}

  @compile {:inline, get_component: 2, empty_value?: 1}

  @doc "Parses a wire-format value into a typed Elixir value."
  @callback parse(list() | binary()) :: struct() | binary() | nil

  @doc "Encodes a typed Elixir value back to wire format."
  @callback encode(struct() | binary() | nil) :: list() | binary()

  @sub_component_key :hl7v2_sub_component_sep

  @doc """
  Returns the active sub-component separator string.

  Defaults to `"&"` when no separator context has been set via
  `with_sub_component_separator/2`.
  """
  @spec sub_component_separator() :: binary()
  def sub_component_separator do
    Process.get(@sub_component_key, "&")
  end

  @doc """
  Executes `fun` with the given sub-component separator active.

  The separator is stored in the process dictionary for the duration of `fun`
  and restored to its previous value afterwards. This is used by segment
  parse/encode to propagate the message's actual sub-component delimiter to
  all composite type helpers.
  """
  @spec with_sub_component_separator(binary(), (-> result)) :: result when result: term()
  def with_sub_component_separator(sep, fun) when is_binary(sep) and is_function(fun, 0) do
    previous = Process.get(@sub_component_key)
    Process.put(@sub_component_key, sep)

    try do
      fun.()
    after
      case previous do
        nil -> Process.delete(@sub_component_key)
        val -> Process.put(@sub_component_key, val)
      end
    end
  end

  @doc """
  Extracts a string value from a component, returning `nil` for empty/nil inputs.

  Used internally by composite type parsers to normalize component access.
  """
  @spec get_component(list(), non_neg_integer()) :: binary() | nil
  def get_component(components, index) when is_list(components) do
    case Enum.at(components, index) do
      nil -> nil
      "" -> nil
      value when is_binary(value) -> value
      subs when is_list(subs) -> rejoin_sub_components(subs)
      _other -> nil
    end
  end

  # When the raw parser has already split sub-components into a list,
  # rejoin them with the sub-component delimiter so that composite type
  # parsers (CX, XPN, etc.) can re-split and parse them as expected.
  defp rejoin_sub_components(subs) do
    if Enum.all?(subs, &(&1 == "" or is_nil(&1))) do
      nil
    else
      Enum.join(subs, sub_component_separator())
    end
  end

  @doc """
  Pads a list of components to the given length with nils.
  """
  @spec pad_components(list(), non_neg_integer()) :: list()
  def pad_components(components, length) when is_list(components) do
    current = length(components)

    if current >= length do
      components
    else
      components ++ List.duplicate(nil, length - current)
    end
  end

  @doc """
  Trims trailing nil/empty values from a list of components for compact encoding.
  """
  @spec trim_trailing(list()) :: list()
  def trim_trailing(components) when is_list(components) do
    components
    |> Enum.reverse()
    |> Enum.drop_while(&empty_value?/1)
    |> Enum.reverse()
  end

  defp empty_value?(nil), do: true
  defp empty_value?(""), do: true
  defp empty_value?([]), do: true
  defp empty_value?(_), do: false

  # --- Sub-component helpers ---
  # Shared by all composite type modules that embed other composite types
  # as sub-components (CX, XCN, XPN, XAD, PL, NDL, XON, EIP, etc.).

  @doc """
  Returns `true` if every field in the given struct is `nil`.

  Used after parsing a sub-component to decide whether the result is
  effectively empty and should be returned as `nil`.

  ## Examples

      iex> HL7v2.Type.all_nil?(%HL7v2.Type.HD{})
      true

      iex> HL7v2.Type.all_nil?(%HL7v2.Type.HD{namespace_id: "MRN"})
      false

  """
  @spec all_nil?(struct()) :: boolean()
  def all_nil?(struct) do
    struct
    |> Map.from_struct()
    |> Map.values()
    |> Enum.all?(&is_nil/1)
  end

  @doc """
  Parses a sub-component string into the given composite type's struct.

  Splits `value` on the active sub-component separator, delegates to
  `module.parse/1`, and returns `nil` if all fields in the resulting
  struct are `nil`.

  Returns `nil` for `nil` input.

  ## Examples

      iex> HL7v2.Type.parse_sub(HL7v2.Type.HD, "MRN&1.2.3&ISO")
      %HL7v2.Type.HD{namespace_id: "MRN", universal_id: "1.2.3", universal_id_type: "ISO"}

      iex> HL7v2.Type.parse_sub(HL7v2.Type.HD, nil)
      nil

  """
  @spec parse_sub(module(), binary() | nil) :: struct() | nil
  def parse_sub(_module, nil), do: nil

  def parse_sub(module, value) when is_binary(value) do
    subs = String.split(value, sub_component_separator())
    parsed = module.parse(subs)
    if all_nil?(parsed), do: nil, else: parsed
  end

  @doc """
  Encodes a sub-component struct back to a sub-component-separated string.

  Delegates to `module.encode/1` and joins the result with the active
  sub-component separator.

  Returns `""` for `nil` input.

  ## Examples

      iex> HL7v2.Type.encode_sub(HL7v2.Type.HD, %HL7v2.Type.HD{namespace_id: "MRN", universal_id: "1.2.3", universal_id_type: "ISO"})
      "MRN&1.2.3&ISO"

      iex> HL7v2.Type.encode_sub(HL7v2.Type.HD, nil)
      ""

  """
  @spec encode_sub(module(), struct() | nil) :: binary()
  def encode_sub(_module, nil), do: ""

  def encode_sub(module, struct) do
    module.encode(struct) |> Enum.join(sub_component_separator())
  end

  @doc """
  Parses a sub-component TS (Time Stamp) value.

  Like `parse_sub/2` but uses the TS-specific nil check: a TS is
  considered nil when both `time` and `degree_of_precision` are nil.

  ## Examples

      iex> HL7v2.Type.parse_sub_ts("20260322143000")
      %HL7v2.Type.TS{time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22, hour: 14, minute: 30, second: 0}}

      iex> HL7v2.Type.parse_sub_ts(nil)
      nil

  """
  @spec parse_sub_ts(binary() | nil) :: TS.t() | nil
  def parse_sub_ts(nil), do: nil

  def parse_sub_ts(value) when is_binary(value) do
    subs = String.split(value, sub_component_separator())
    ts_val = TS.parse(subs)
    if all_nil?(ts_val), do: nil, else: ts_val
  end

  @doc """
  Encodes a sub-component TS or DTM value to a sub-component-separated string.

  Handles both `%TS{}` structs (encoded as sub-component list) and bare
  `%DTM{}` structs (encoded directly as a date-time string).

  Returns `""` for `nil` input.

  ## Examples

      iex> HL7v2.Type.encode_sub_ts(%HL7v2.Type.TS{time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22}})
      "20260322"

      iex> HL7v2.Type.encode_sub_ts(%HL7v2.Type.DTM{year: 2026, month: 3, day: 22})
      "20260322"

      iex> HL7v2.Type.encode_sub_ts(nil)
      ""

  """
  @spec encode_sub_ts(TS.t() | DTM.t() | nil) :: binary()
  def encode_sub_ts(nil), do: ""

  def encode_sub_ts(%TS{} = ts) do
    case TS.encode(ts) do
      [] -> ""
      parts -> Enum.join(parts, sub_component_separator())
    end
  end

  def encode_sub_ts(%DTM{} = dtm) do
    DTM.encode(dtm)
  end
end
