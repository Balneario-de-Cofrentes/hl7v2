defmodule HL7v2.Type.CQ do
  @moduledoc """
  Composite Quantity with Units (CQ) -- HL7v2 composite data type.

  Used for quantities with associated units.

  2 components:
  1. Quantity (NM)
  2. Units (CE) -- sub-components delimited by `&`
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.CE

  defstruct [:quantity, :units]

  @type t :: %__MODULE__{
          quantity: binary() | nil,
          units: CE.t() | nil
        }

  @doc """
  Parses a CQ from a list of components.

  ## Examples

      iex> HL7v2.Type.CQ.parse(["10", "mL&milliliter&UCUM"])
      %HL7v2.Type.CQ{quantity: "10", units: %HL7v2.Type.CE{identifier: "mL", text: "milliliter", name_of_coding_system: "UCUM"}}

      iex> HL7v2.Type.CQ.parse(["5"])
      %HL7v2.Type.CQ{quantity: "5"}

      iex> HL7v2.Type.CQ.parse([])
      %HL7v2.Type.CQ{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      quantity: Type.get_component(components, 0),
      units: Type.parse_sub(CE, Type.get_component(components, 1))
    }
  end

  @doc """
  Encodes a CQ to a list of component strings.

  ## Examples

      iex> HL7v2.Type.CQ.encode(%HL7v2.Type.CQ{quantity: "10", units: %HL7v2.Type.CE{identifier: "mL"}})
      ["10", "mL"]

      iex> HL7v2.Type.CQ.encode(%HL7v2.Type.CQ{quantity: "5"})
      ["5"]

      iex> HL7v2.Type.CQ.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = cq) do
    [
      cq.quantity || "",
      Type.encode_sub(CE, cq.units)
    ]
    |> Type.trim_trailing()
  end
end
