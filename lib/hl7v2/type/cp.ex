defmodule HL7v2.Type.CP do
  @moduledoc """
  Composite Price (CP) -- HL7v2 composite data type.

  Used for price information with optional range and type qualifiers.

  6 components:
  1. Price (MO) -- sub-components delimited by `&` (quantity & denomination)
  2. Price Type (ID) -- Table 0205
  3. From Value (NM)
  4. To Value (NM)
  5. Range Units (CE) -- sub-components delimited by `&`
  6. Range Type (ID) -- Table 0298
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.{MO, CE}

  defstruct [:price, :price_type, :from_value, :to_value, :range_units, :range_type]

  @type t :: %__MODULE__{
          price: MO.t() | nil,
          price_type: binary() | nil,
          from_value: binary() | nil,
          to_value: binary() | nil,
          range_units: CE.t() | nil,
          range_type: binary() | nil
        }

  @doc """
  Parses a CP from a list of components.

  ## Examples

      iex> HL7v2.Type.CP.parse(["100.00&USD", "UP"])
      %HL7v2.Type.CP{price: %HL7v2.Type.MO{quantity: "100.00", denomination: "USD"}, price_type: "UP"}

      iex> HL7v2.Type.CP.parse(["50"])
      %HL7v2.Type.CP{price: %HL7v2.Type.MO{quantity: "50"}}

      iex> HL7v2.Type.CP.parse([])
      %HL7v2.Type.CP{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      price: parse_sub_mo(Type.get_component(components, 0)),
      price_type: Type.get_component(components, 1),
      from_value: Type.get_component(components, 2),
      to_value: Type.get_component(components, 3),
      range_units: parse_sub_ce(Type.get_component(components, 4)),
      range_type: Type.get_component(components, 5)
    }
  end

  @doc """
  Encodes a CP to a list of component strings.

  ## Examples

      iex> HL7v2.Type.CP.encode(%HL7v2.Type.CP{price: %HL7v2.Type.MO{quantity: "100.00", denomination: "USD"}, price_type: "UP"})
      ["100.00&USD", "UP"]

      iex> HL7v2.Type.CP.encode(%HL7v2.Type.CP{price: %HL7v2.Type.MO{quantity: "50"}})
      ["50"]

      iex> HL7v2.Type.CP.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = cp) do
    [
      encode_sub_mo(cp.price),
      cp.price_type || "",
      cp.from_value || "",
      cp.to_value || "",
      encode_sub_ce(cp.range_units),
      cp.range_type || ""
    ]
    |> Type.trim_trailing()
  end

  defp parse_sub_mo(nil), do: nil

  defp parse_sub_mo(value) when is_binary(value) do
    subs = String.split(value, "&")
    mo_val = MO.parse(subs)
    if mo_val.quantity == nil and mo_val.denomination == nil, do: nil, else: mo_val
  end

  defp encode_sub_mo(nil), do: ""

  defp encode_sub_mo(%MO{} = mo) do
    mo |> MO.encode() |> Enum.join("&")
  end

  defp parse_sub_ce(nil), do: nil

  defp parse_sub_ce(value) when is_binary(value) do
    subs = String.split(value, "&")
    ce_val = CE.parse(subs)
    if all_nil?(ce_val), do: nil, else: ce_val
  end

  defp encode_sub_ce(nil), do: ""

  defp encode_sub_ce(%CE{} = ce) do
    ce |> CE.encode() |> Enum.join("&")
  end

  defp all_nil?(struct) do
    struct
    |> Map.from_struct()
    |> Map.values()
    |> Enum.all?(&is_nil/1)
  end
end
