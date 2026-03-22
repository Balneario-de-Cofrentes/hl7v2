defmodule HL7v2.Type.DLN do
  @moduledoc """
  Driver's License Number (DLN) -- HL7v2 composite data type.

  Used for driver's license identification.

  3 components:
  1. License Number (ST)
  2. Issuing State, Province, Country (IS) -- Table 0333
  3. Expiration Date (DT)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.DT

  defstruct [:license_number, :issuing_state_province_country, :expiration_date]

  @type t :: %__MODULE__{
          license_number: binary() | nil,
          issuing_state_province_country: binary() | nil,
          expiration_date: Date.t() | DT.t() | nil
        }

  @doc """
  Parses a DLN from a list of components.

  ## Examples

      iex> HL7v2.Type.DLN.parse(["S12345678", "CA", "20280101"])
      %HL7v2.Type.DLN{license_number: "S12345678", issuing_state_province_country: "CA", expiration_date: ~D[2028-01-01]}

      iex> HL7v2.Type.DLN.parse(["S12345678", "CA"])
      %HL7v2.Type.DLN{license_number: "S12345678", issuing_state_province_country: "CA"}

      iex> HL7v2.Type.DLN.parse(["S12345678"])
      %HL7v2.Type.DLN{license_number: "S12345678"}

      iex> HL7v2.Type.DLN.parse([])
      %HL7v2.Type.DLN{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      license_number: Type.get_component(components, 0),
      issuing_state_province_country: Type.get_component(components, 1),
      expiration_date: components |> Type.get_component(2) |> DT.parse()
    }
  end

  @doc """
  Encodes a DLN to a list of component strings.

  ## Examples

      iex> HL7v2.Type.DLN.encode(%HL7v2.Type.DLN{license_number: "S12345678", issuing_state_province_country: "CA", expiration_date: ~D[2028-01-01]})
      ["S12345678", "CA", "20280101"]

      iex> HL7v2.Type.DLN.encode(%HL7v2.Type.DLN{license_number: "S12345678"})
      ["S12345678"]

      iex> HL7v2.Type.DLN.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = dln) do
    [
      dln.license_number || "",
      dln.issuing_state_province_country || "",
      DT.encode(dln.expiration_date)
    ]
    |> Type.trim_trailing()
  end
end
