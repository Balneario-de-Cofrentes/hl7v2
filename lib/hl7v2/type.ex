defmodule HL7v2.Type do
  @moduledoc """
  Base behaviour for HL7v2 data types.

  Every data type module (primitive and composite) implements this behaviour,
  providing `parse/1` and `encode/1` for converting between wire-format
  representations and typed Elixir values.

  Primitive types (ST, NM, DT, etc.) work with binaries.
  Composite types (CX, XPN, HD, etc.) work with lists of component strings
  and return/accept structs.
  """

  @doc "Parses a wire-format value into a typed Elixir value."
  @callback parse(list() | binary()) :: struct() | binary() | nil

  @doc "Encodes a typed Elixir value back to wire format."
  @callback encode(struct() | binary() | nil) :: list() | binary()

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
      Enum.join(subs, "&")
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
end
