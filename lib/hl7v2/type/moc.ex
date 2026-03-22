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
      monetary_amount: parse_sub_mo(Type.get_component(components, 0)),
      charge_code: parse_sub_ce(Type.get_component(components, 1))
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
      encode_sub_mo(moc.monetary_amount),
      encode_sub_ce(moc.charge_code)
    ]
    |> Type.trim_trailing()
  end

  defp parse_sub_mo(nil), do: nil

  defp parse_sub_mo(value) when is_binary(value) do
    subs = String.split(value, Type.sub_component_separator())
    mo_val = MO.parse(subs)
    if mo_val.quantity == nil and mo_val.denomination == nil, do: nil, else: mo_val
  end

  defp parse_sub_ce(nil), do: nil

  defp parse_sub_ce(value) when is_binary(value) do
    subs = String.split(value, Type.sub_component_separator())
    ce_val = CE.parse(subs)
    if all_nil?(ce_val), do: nil, else: ce_val
  end

  defp encode_sub_mo(nil), do: ""

  defp encode_sub_mo(%MO{} = mo),
    do: mo |> MO.encode() |> Enum.join(Type.sub_component_separator())

  defp encode_sub_ce(nil), do: ""

  defp encode_sub_ce(%CE{} = ce),
    do: ce |> CE.encode() |> Enum.join(Type.sub_component_separator())

  defp all_nil?(struct) do
    struct
    |> Map.from_struct()
    |> Map.values()
    |> Enum.all?(&is_nil/1)
  end
end
