defmodule HL7v2.Type.PLN do
  @moduledoc """
  Practitioner License or Other ID Number (PLN) -- HL7v2 composite data type.

  Used to transmit a practitioner's license or other identification number
  along with contextual information.

  4 components:
  1. ID Number (ST) -- the license or ID number
  2. Type of ID Number (IS) -- Table 0338: e.g., "MD", "DO", "RN", "DEA"
  3. State/Other Qualifying Information (ST) -- jurisdiction, e.g., "CA", "NY"
  4. Expiration Date (DT) -- YYYY[MM[DD]]
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.DT

  defstruct [
    :id_number,
    :type_of_id_number,
    :state_other_qualifying_information,
    :expiration_date
  ]

  @type t :: %__MODULE__{
          id_number: binary() | nil,
          type_of_id_number: binary() | nil,
          state_other_qualifying_information: binary() | nil,
          expiration_date: Date.t() | DT.t() | nil
        }

  @doc """
  Parses a PLN from a list of components.

  ## Examples

      iex> HL7v2.Type.PLN.parse(["A12345", "MD", "CA", "20281231"])
      %HL7v2.Type.PLN{id_number: "A12345", type_of_id_number: "MD", state_other_qualifying_information: "CA", expiration_date: ~D[2028-12-31]}

      iex> HL7v2.Type.PLN.parse(["DEA98765", "DEA"])
      %HL7v2.Type.PLN{id_number: "DEA98765", type_of_id_number: "DEA"}

      iex> HL7v2.Type.PLN.parse([])
      %HL7v2.Type.PLN{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      id_number: Type.get_component(components, 0),
      type_of_id_number: Type.get_component(components, 1),
      state_other_qualifying_information: Type.get_component(components, 2),
      expiration_date: components |> Type.get_component(3) |> DT.parse()
    }
  end

  @doc """
  Encodes a PLN to a list of component strings.

  ## Examples

      iex> HL7v2.Type.PLN.encode(%HL7v2.Type.PLN{id_number: "A12345", type_of_id_number: "MD", state_other_qualifying_information: "CA", expiration_date: ~D[2028-12-31]})
      ["A12345", "MD", "CA", "20281231"]

      iex> HL7v2.Type.PLN.encode(%HL7v2.Type.PLN{id_number: "DEA98765", type_of_id_number: "DEA"})
      ["DEA98765", "DEA"]

      iex> HL7v2.Type.PLN.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = pln) do
    [
      pln.id_number || "",
      pln.type_of_id_number || "",
      pln.state_other_qualifying_information || "",
      DT.encode(pln.expiration_date)
    ]
    |> Type.trim_trailing()
  end
end
