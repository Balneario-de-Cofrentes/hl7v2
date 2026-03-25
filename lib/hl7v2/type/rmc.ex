defmodule HL7v2.Type.RMC do
  @moduledoc """
  Room Coverage (RMC) -- HL7v2 composite data type.

  Specifies room coverage type, amount, and percentage for insurance.

  4 components:
  1. Room Type (IS) -- Table 0145: e.g., "PR" (private), "SP" (semi-private)
  2. Amount Type (IS) -- Table 0146: e.g., "LM" (limit), "PC" (percentage), "UP" (unlimited)
  3. Coverage Amount (NM) -- the numeric coverage value
  4. Money or Percentage (MOP) -- v2.5.1 added; rarely populated, treated as ST
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.NM

  defstruct [
    :room_type,
    :amount_type,
    :coverage_amount,
    :money_or_percentage
  ]

  @type t :: %__MODULE__{
          room_type: binary() | nil,
          amount_type: binary() | nil,
          coverage_amount: NM.t() | nil,
          money_or_percentage: binary() | nil
        }

  @doc """
  Parses an RMC from a list of components.

  ## Examples

      iex> HL7v2.Type.RMC.parse(["PR", "LM", "500"])
      %HL7v2.Type.RMC{room_type: "PR", amount_type: "LM", coverage_amount: %HL7v2.Type.NM{value: "500", original: "500"}}

      iex> HL7v2.Type.RMC.parse([])
      %HL7v2.Type.RMC{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      room_type: Type.get_component(components, 0),
      amount_type: Type.get_component(components, 1),
      coverage_amount: components |> Type.get_component(2) |> NM.parse(),
      money_or_percentage: Type.get_component(components, 3)
    }
  end

  @doc """
  Encodes an RMC to a list of component strings.

  ## Examples

      iex> HL7v2.Type.RMC.encode(%HL7v2.Type.RMC{room_type: "PR", amount_type: "LM", coverage_amount: %HL7v2.Type.NM{value: "500", original: "500"}})
      ["PR", "LM", "500"]

      iex> HL7v2.Type.RMC.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = rmc) do
    [
      rmc.room_type || "",
      rmc.amount_type || "",
      NM.encode(rmc.coverage_amount),
      rmc.money_or_percentage || ""
    ]
    |> Type.trim_trailing()
  end
end
