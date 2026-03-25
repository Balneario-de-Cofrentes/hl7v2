defmodule HL7v2.Type.PTA do
  @moduledoc """
  Policy Type and Amount (PTA) -- HL7v2 composite data type.

  Specifies a policy type, amount class, and money/percentage value for insurance.

  3 components:
  1. Policy Type (IS) -- Table 0147: e.g., "ANC" (ancillary), "2ANC" (second ancillary)
  2. Amount Class (IS) -- Table 0193: e.g., "LM" (limit), "PC" (percentage), "UP" (unlimited)
  3. Money or Percentage Quantity (NM) -- the numeric value
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.NM

  defstruct [
    :policy_type,
    :amount_class,
    :money_or_percentage_quantity
  ]

  @type t :: %__MODULE__{
          policy_type: binary() | nil,
          amount_class: binary() | nil,
          money_or_percentage_quantity: NM.t() | nil
        }

  @doc """
  Parses a PTA from a list of components.

  ## Examples

      iex> HL7v2.Type.PTA.parse(["ANC", "LM", "1000"])
      %HL7v2.Type.PTA{policy_type: "ANC", amount_class: "LM", money_or_percentage_quantity: %HL7v2.Type.NM{value: "1000", original: "1000"}}

      iex> HL7v2.Type.PTA.parse([])
      %HL7v2.Type.PTA{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      policy_type: Type.get_component(components, 0),
      amount_class: Type.get_component(components, 1),
      money_or_percentage_quantity: components |> Type.get_component(2) |> NM.parse()
    }
  end

  @doc """
  Encodes a PTA to a list of component strings.

  ## Examples

      iex> HL7v2.Type.PTA.encode(%HL7v2.Type.PTA{policy_type: "ANC", amount_class: "LM", money_or_percentage_quantity: %HL7v2.Type.NM{value: "1000", original: "1000"}})
      ["ANC", "LM", "1000"]

      iex> HL7v2.Type.PTA.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = pta) do
    [
      pta.policy_type || "",
      pta.amount_class || "",
      NM.encode(pta.money_or_percentage_quantity)
    ]
    |> Type.trim_trailing()
  end
end
