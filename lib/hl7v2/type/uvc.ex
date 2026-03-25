defmodule HL7v2.Type.UVC do
  @moduledoc """
  UB Value Code and Amount (UVC) -- HL7v2 composite data type.

  Links a UB value code to its monetary amount for billing segments
  (UB1-10, UB2-6).

  2 components:
  1. Value Code (CNE) -- sub-components, Table 0153
  2. Value Amount (MO) -- sub-components (quantity & denomination)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.{CNE, MO}

  defstruct [
    :value_code,
    :value_amount
  ]

  @type t :: %__MODULE__{
          value_code: CNE.t() | nil,
          value_amount: MO.t() | nil
        }

  @doc """
  Parses a UVC from a list of components.

  ## Examples

      iex> HL7v2.Type.UVC.parse(["01&Blood deductible&NUBC", "150.00&USD"])
      %HL7v2.Type.UVC{
        value_code: %HL7v2.Type.CNE{identifier: "01", text: "Blood deductible", name_of_coding_system: "NUBC"},
        value_amount: %HL7v2.Type.MO{quantity: "150.00", denomination: "USD"}
      }

      iex> HL7v2.Type.UVC.parse([])
      %HL7v2.Type.UVC{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      value_code: Type.parse_sub(CNE, Type.get_component(components, 0)),
      value_amount: Type.parse_sub(MO, Type.get_component(components, 1))
    }
  end

  @doc """
  Encodes a UVC to a list of component strings.

  ## Examples

      iex> HL7v2.Type.UVC.encode(%HL7v2.Type.UVC{value_code: %HL7v2.Type.CNE{identifier: "01"}, value_amount: %HL7v2.Type.MO{quantity: "150.00"}})
      ["01", "150.00"]

      iex> HL7v2.Type.UVC.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = uvc) do
    [
      Type.encode_sub(CNE, uvc.value_code),
      Type.encode_sub(MO, uvc.value_amount)
    ]
    |> Type.trim_trailing()
  end
end
