defmodule HL7v2.Type.DDI do
  @moduledoc """
  Daily Deductible Information (DDI) -- HL7v2 composite data type.

  Specifies the daily deductible parameters for insurance coverage.

  3 components:
  1. Delay Days (NM) -- number of delay days before the deductible applies
  2. Monetary Amount (MO) -- daily deductible amount (sub-components: quantity & denomination)
  3. Number of Days (NM) -- number of days the deductible is in effect
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.{MO, NM}

  defstruct [
    :delay_days,
    :monetary_amount,
    :number_of_days
  ]

  @type t :: %__MODULE__{
          delay_days: NM.t() | nil,
          monetary_amount: MO.t() | nil,
          number_of_days: NM.t() | nil
        }

  @doc """
  Parses a DDI from a list of components.

  ## Examples

      iex> HL7v2.Type.DDI.parse(["3", "100.00&USD", "30"])
      %HL7v2.Type.DDI{
        delay_days: %HL7v2.Type.NM{value: "3", original: "3"},
        monetary_amount: %HL7v2.Type.MO{quantity: "100.00", denomination: "USD"},
        number_of_days: %HL7v2.Type.NM{value: "30", original: "30"}
      }

      iex> HL7v2.Type.DDI.parse([])
      %HL7v2.Type.DDI{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      delay_days: components |> Type.get_component(0) |> NM.parse(),
      monetary_amount: Type.parse_sub(MO, Type.get_component(components, 1)),
      number_of_days: components |> Type.get_component(2) |> NM.parse()
    }
  end

  @doc """
  Encodes a DDI to a list of component strings.

  ## Examples

      iex> HL7v2.Type.DDI.encode(%HL7v2.Type.DDI{delay_days: %HL7v2.Type.NM{value: "3", original: "3"}, number_of_days: %HL7v2.Type.NM{value: "30", original: "30"}})
      ["3", "", "30"]

      iex> HL7v2.Type.DDI.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = ddi) do
    [
      NM.encode(ddi.delay_days),
      Type.encode_sub(MO, ddi.monetary_amount),
      NM.encode(ddi.number_of_days)
    ]
    |> Type.trim_trailing()
  end
end
