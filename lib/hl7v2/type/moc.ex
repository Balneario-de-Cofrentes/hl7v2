defmodule HL7v2.Type.MOC do
  @moduledoc """
  Money and Charge Code (MOC) -- HL7v2 composite data type.

  Used to convey a monetary amount together with a charge code.

  2 components:
  1. Monetary Amount (MO) -- sub-components delimited by `&`
  2. Charge Code (CE) -- sub-components delimited by `&`
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.{CE, MO}

  defstruct [:monetary_amount, :charge_code]

  @type t :: %__MODULE__{
          monetary_amount: MO.t() | nil,
          charge_code: CE.t() | nil
        }

  @doc """
  Parses a MOC from a list of components.

  ## Examples

      iex> HL7v2.Type.MOC.parse(["150.00&USD", "99213&Office Visit&CPT4"])
      %HL7v2.Type.MOC{
        monetary_amount: %HL7v2.Type.MO{quantity: "150.00", denomination: "USD"},
        charge_code: %HL7v2.Type.CE{identifier: "99213", text: "Office Visit", name_of_coding_system: "CPT4"}
      }

      iex> HL7v2.Type.MOC.parse(["150.00&USD"])
      %HL7v2.Type.MOC{monetary_amount: %HL7v2.Type.MO{quantity: "150.00", denomination: "USD"}}

      iex> HL7v2.Type.MOC.parse([])
      %HL7v2.Type.MOC{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      monetary_amount: Type.parse_sub(MO, Type.get_component(components, 0)),
      charge_code: Type.parse_sub(CE, Type.get_component(components, 1))
    }
  end

  @doc """
  Encodes a MOC to a list of component strings.

  ## Examples

      iex> HL7v2.Type.MOC.encode(%HL7v2.Type.MOC{monetary_amount: %HL7v2.Type.MO{quantity: "150.00", denomination: "USD"}})
      ["150.00&USD"]

      iex> HL7v2.Type.MOC.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = moc) do
    [
      Type.encode_sub(MO, moc.monetary_amount),
      Type.encode_sub(CE, moc.charge_code)
    ]
    |> Type.trim_trailing()
  end
end
