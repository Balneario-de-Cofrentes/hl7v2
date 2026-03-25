defmodule HL7v2.Type.MOP do
  @moduledoc """
  Money or Percentage (MOP) -- HL7v2 composite data type.

  Transmits a monetary amount or a percentage.

  2 components:
  1. Money or Percentage Indicator (ID) -- AT (amount), PC (percentage)
  2. Money or Percentage Quantity (NM)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [:money_or_percentage_indicator, :money_or_percentage_quantity]

  @type t :: %__MODULE__{
          money_or_percentage_indicator: binary() | nil,
          money_or_percentage_quantity: binary() | nil
        }

  @doc """
  Parses a MOP from a list of components.

  ## Examples

      iex> HL7v2.Type.MOP.parse(["AT", "150.00"])
      %HL7v2.Type.MOP{money_or_percentage_indicator: "AT", money_or_percentage_quantity: "150.00"}

      iex> HL7v2.Type.MOP.parse(["PC", "80"])
      %HL7v2.Type.MOP{money_or_percentage_indicator: "PC", money_or_percentage_quantity: "80"}

      iex> HL7v2.Type.MOP.parse([])
      %HL7v2.Type.MOP{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      money_or_percentage_indicator: Type.get_component(components, 0),
      money_or_percentage_quantity: Type.get_component(components, 1)
    }
  end

  @doc """
  Encodes a MOP to a list of component strings.

  ## Examples

      iex> HL7v2.Type.MOP.encode(%HL7v2.Type.MOP{money_or_percentage_indicator: "AT", money_or_percentage_quantity: "150.00"})
      ["AT", "150.00"]

      iex> HL7v2.Type.MOP.encode(%HL7v2.Type.MOP{money_or_percentage_indicator: "PC"})
      ["PC"]

      iex> HL7v2.Type.MOP.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = mop) do
    [
      mop.money_or_percentage_indicator || "",
      mop.money_or_percentage_quantity || ""
    ]
    |> Type.trim_trailing()
  end
end
