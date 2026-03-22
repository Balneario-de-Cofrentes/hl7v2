defmodule HL7v2.Type.MO do
  @moduledoc """
  Money (MO) -- HL7v2 composite data type.

  Used for monetary amounts with optional denomination.

  2 components:
  1. Quantity (NM)
  2. Denomination (ID) -- ISO 4217 currency code (e.g., USD, EUR)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [:quantity, :denomination]

  @type t :: %__MODULE__{
          quantity: binary() | nil,
          denomination: binary() | nil
        }

  @doc """
  Parses an MO from a list of components.

  ## Examples

      iex> HL7v2.Type.MO.parse(["150.00", "USD"])
      %HL7v2.Type.MO{quantity: "150.00", denomination: "USD"}

      iex> HL7v2.Type.MO.parse(["250"])
      %HL7v2.Type.MO{quantity: "250"}

      iex> HL7v2.Type.MO.parse([])
      %HL7v2.Type.MO{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      quantity: Type.get_component(components, 0),
      denomination: Type.get_component(components, 1)
    }
  end

  @doc """
  Encodes an MO to a list of component strings.

  ## Examples

      iex> HL7v2.Type.MO.encode(%HL7v2.Type.MO{quantity: "150.00", denomination: "USD"})
      ["150.00", "USD"]

      iex> HL7v2.Type.MO.encode(%HL7v2.Type.MO{quantity: "250"})
      ["250"]

      iex> HL7v2.Type.MO.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = mo) do
    [
      mo.quantity || "",
      mo.denomination || ""
    ]
    |> Type.trim_trailing()
  end
end
